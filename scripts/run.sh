#!/usr/bin/env bash
set -euo pipefail

STACK_NAME=ha_stack
NETWORK=ha_overlay
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"

echo "Deploying stack '$STACK_NAME' from '$ROOT_DIR'..."

# 1. Initialize swarm if needed
if [ "$(docker info --format '{{.Swarm.LocalNodeState}}')" != "active" ]; then
  docker swarm init
fi

# 2. Create overlay network
if ! docker network inspect "$NETWORK" >/dev/null 2>&1; then
  docker network create --driver overlay "$NETWORK"
fi

# 3. Ask which block device to use for the LVM volume
echo
echo "!! WARNING: This will ERASE all data on the device you choose!!"
echo

# 3a. Detect your root device and list all disks
ROOT_DEV=$(findmnt -nvo SOURCE / | sed 's/[0-9]*$//')
mapfile -t DEVICES < <(lsblk -dno NAME,TYPE | awk '$2=="disk"{print "/dev/"$1}')

echo "Available devices:"
for d in "${DEVICES[@]}"; do
  echo "  - $d"
done
echo

# 3b. Loop until you pick a valid non-root device
while true; do
  read -rp "Enter a block device for DB storage: " VOLUME_DEVICE

  if [[ "$VOLUME_DEVICE" == "$ROOT_DEV" ]]; then
    echo "You picked the root device ($ROOT_DEV). That will break your system. Try again."
    continue
  fi

  if [[ ! " ${DEVICES[*]} " =~ " ${VOLUME_DEVICE} " ]]; then
    echo "'$VOLUME_DEVICE' is not in the list. Try again."
    continue
  fi

  break
done

# 3c. Build LVM on the chosen device
VG=vg_ha
LV=lv_db
MOUNT_POINT=/mnt/ha_db

if ! lvdisplay "/dev/$VG/$LV" >/dev/null 2>&1; then
  pvcreate "$VOLUME_DEVICE"
  vgcreate "$VG" "$VOLUME_DEVICE"
  lvcreate -n "$LV" -l 100%FREE "$VG"
  mkfs.xfs "/dev/$VG/$LV"
fi

# 3d. Mount it if needed and persist in /etc/fstab
if ! mountpoint -q "$MOUNT_POINT"; then
  mkdir -p "$MOUNT_POINT"
  mount "/dev/$VG/$LV" "$MOUNT_POINT"
  grep -qF "/dev/$VG/$LV" /etc/fstab \
    || echo "/dev/$VG/$LV $MOUNT_POINT xfs defaults 0 0" >> /etc/fstab
fi

# 4. (Re)generate .env so deployment can use it
"$SCRIPTS_DIR/generate-secrets.sh"

# 5. Export .env into this shell so Swarm can interpolate ${…}
ENV_FILE="$ROOT_DIR/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
else
  echo "ERROR: .env not found at $ENV_FILE" >&2
  exit 1
fi

# 6. Build the images (Swarm ignores build: in stack files)
docker build -t ha-app-db:latest  -f "$ROOT_DIR/db/Dockerfile"  "$ROOT_DIR/db"
docker build -t ha-app-web:latest -f "$ROOT_DIR/web/Dockerfile" "$ROOT_DIR"

# 7. Deploy the stack (with variable interpolation now in effect)
docker stack deploy -c "$ROOT_DIR/docker-stack.yml" "$STACK_NAME"
echo "Deployed stack '$STACK_NAME'"
