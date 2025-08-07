#!/usr/bin/env bash
set -euo pipefail

STACK_NAME=ha_stack
NETWORK=ha_overlay
IMAGES=(ha-app-db:latest ha-app-web:latest)

# LVM settings (must match run.sh)
VG=vg_ha
LV=lv_db
MOUNT_POINT=/mnt/ha_db

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"

echo "Tearing down stack '$STACK_NAME' from '$ROOT_DIR'..."

# 1. Remove stack if present
if docker stack ls --format '{{.Name}}' | grep -qx "$STACK_NAME"; then
  docker stack rm "$STACK_NAME" || true
else
  echo "Stack '$STACK_NAME' not present."
fi

# 2. Wait up to 60s for all services of this stack to vanish
echo -n "Waiting for stack resources to stop"
for _ in $(seq 1 60); do
  if ! docker service ls --format '{{.Name}}' | grep -q "^${STACK_NAME}_" 2>/dev/null; then
    break
  fi
  echo -n "."
  sleep 1
done
echo

# 3. Remove networks (external & stack-scoped)
for net in "$NETWORK" "${STACK_NAME}_${NETWORK}"; do
  if docker network inspect "$net" >/dev/null 2>&1; then
    docker network rm "$net" 2>/dev/null || true
  fi
done

# 4. Remove images
for img in "${IMAGES[@]}"; do
  docker rmi "$img" 2>/dev/null || true
done

# 5. Remove .env
rm -f "$ENV_FILE"

# 6. Clean up LVM

# 6a. Unmount the LV if mounted
if mountpoint -q "$MOUNT_POINT"; then
  umount "$MOUNT_POINT"
fi

# 6b. Remove fstab entry
grep -q "/dev/$VG/$LV" /etc/fstab && \
  sed -i "\|/dev/$VG/$LV|d" /etc/fstab

# 6c. Capture PV list before VG removal
PV_LIST=$(pvs --noheadings -o pv_name "$VG" 2>/dev/null | xargs || true)

# 6d. Remove LV and VG if they exist
if lvdisplay "/dev/$VG/$LV" >/dev/null 2>&1; then
  lvremove -f "/dev/$VG/$LV"
fi
if vgdisplay "$VG" >/dev/null 2>&1; then
  vgremove -f "$VG"
fi

# 6e. Wipe PV labels
for pv in $PV_LIST; do
  pvremove -f "$pv" 2>/dev/null || true
done

# 6f. Remove mount directory if empty
[ -d "$MOUNT_POINT" ] && rmdir "$MOUNT_POINT" 2>/dev/null || true

echo "Teardown complete."