# About HA-Container-Deploy

**HA Container Deploy** is a one-step solution for deploying a high-availability PHP + NGINX web application with a MariaDB database on Docker Swarm. Key features include:
- **High Availability**:Three synced PHP + NGINX replicas with a shared MariaDB backend.
- **Built-in HTTPS**: Caddy handles TLS, reverse proxy, and load balancing.
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

Before you begin, make sure you have the following:
- **Ubuntu** 24.04 LTS
- **Docker** 28.3.2
- **Docker Compose** 2.38.2
- **gcloud CLI** with Owner or Editor role
- **Open ports 80 and 443** in both OS and GCP firewall
    - These are required for HTTP and HTTPS access to the load balancer
- **Close ports 8000 and 5432** in both OS and GCP firewall
    - These ports are used only inside the container network
    - The load balancer forwards external traffic to the app on port 8000
    - The app connects to the database on port 5432 internally

> **Note:** These are the exact versions used during development. Newer releases, such as newer Docker or Docker Compose versions, may work but aren't verified.

## Google Cloud Platform (GCP) Setup

```
(Work-In-Progress)
```

## Installation Setup

```
(Work-In-Progress)
```
