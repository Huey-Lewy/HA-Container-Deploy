# About HA-Container-Deploy

**HA Container Deploy** is a one-step solution for deploying a high-availability PHP + NGINX web application with a MariaDB database on Docker Swarm. Key features include:
- **High Availability**: Three synced PHP + NGINX replicas with a shared MariaDB backend.
- **Load Balanced**: Caddy listens on port 80 for HTTP, acting as a reverse proxy and distributing incoming requests across all web replicas evenly.
- **Automatic Scalability**: When the 2 replica "NGINX + PHP" containers ("web" containers) are under load, they will automatically scale up to 4 total containers. 
- **One-Step Deployment**: Scripts handles managing secrets, networks, volumes, and stack setup.
- **Cloud-Ready**: Optimized and developed for Docker Swarm on a Google Cloud Ubuntu VM instance.

## Repository Layout

```
├── config/                 # Service config files
│   ├── caddy/                  # Caddy reverse proxy + TLS
│   │   └── Caddyfile               # Proxy rules, load balancing, health checks
│   └── nginx/                  # Internal web server
│       └── default.conf            # FastCGI and static file handling
│
├── db/                     # MariaDB
│   ├── Dockerfile              # Build MariaDB image
│   ├── init.sql                # Create score table, seed initial value
│   ├── index.html              # Static page stored as blob in database
│   └── load_index_html.sh      # Load index.html into score table
│
├── scripts/                # Automation scripts
│   ├── generate-secrets.sh     # Create Docker Swarm secrets
│   ├── run.sh                  # Create networks/volumes, deploy stack
│   └── teardown.sh             # Remove stack, clean up resources
│
├── web/                    # PHP + NGINX
│   ├── Dockerfile              # Build PHP/NGINX image
│   └── src/                    # Application source code
│       ├── composer.json           # PHP dependencies
│       ├── index.php               # Fetch score, render page with button
│       └── update_score.php        # Endpoint to increment and return score
│
├── docker-stack.yml    # Swarm stack definition
├── .gitignore  # Git ignore rules
├── LICENSE     # License terms
└── README.md   # Project overview and quick-start
```

## Prerequisites

> **Note:** These are the exact versions used during development. \
> _Newer releases, such as newer Docker or Docker Compose versions, may work but aren't verified._

**Before you begin, make sure you have the following**:
- **Hardware**: At least 2GB of RAM and 1 vCPU
- **Operating System**: Ubuntu 24.04 LTS
- **Software**:
    - Docker 28.3.2
    - Docker Compose 2.38.2
    - gcloud CLI _(Owner or Editor role)_
- **Firewall** (apply on both OS and your GCP VM):
    - **Open Port** `80/TCP` to allow incoming HTTP traffic to Caddy.
        - **Caddy** is the load balancer and reverse proxy.
    - **Close Port** `3306/TCP` to block external access to MariaDB.
        - **MariaDB** only needs to be reachable over the Swarm overlay.


## Installation Setup

```
# 1. Clone the repository
git clone https://github.com/Huey-Lewy/HA-Container-Deploy.git
cd HA-Container-Deploy

# 2. Configure the host firewall
sudo ufw allow 80/tcp    # Allow HTTP traffic for Caddy
sudo ufw deny 3306/tcp   # Block external MariaDB access

# 3. Make deployment scripts executable
sudo chmod +x scripts/*.sh

# 4. Run the one-step deploy (will init Swarm if needed)
sudo ./scripts/run.sh
```

## Verify Installation
```
# 1. Check that the stack is deployed
# You should see "ha_stack"
sudo docker stack ls

# 2. List the services in the stack
# You should see: "ha_stack_db" (1/1), "ha_stack_web" (2/2), and "ha_stack_caddy" (1/1)
sudo docker stack services ha_stack

# 3. Inspect the tasks (containers) for each service
# All containers should be "Running"
sudo docker service ps ha_stack_db
sudo docker service ps ha_stack_web
```

## Teardown & Clean up
```
# To stop and remove the stack, including all created resources, run:
sudo ./scripts/teardown.sh
```