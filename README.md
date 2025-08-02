# About HA-Container-Deploy

**HA Container Deploy** is a one-step solution for deploying a high-availability PHP + NGINX web application with a MariaDB database on Docker Swarm. Key features include:
- **High Availability**: Three synced PHP + NGINX replicas with a shared MariaDB backend.
- **HTTP only**: Caddy listens on port 80 for HTTP, handles reverse proxy and load balancing, and redirects any HTTPS requests on port 443 back to HTTP.
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
    - Port 80 allows HTTP traffic to the load balancer
    - Port 443 allows HTTPS requests to reach Caddy so it can redirect them to HTTP
- **Close port 3306** in both OS and GCP firewall
    - MariaDB's 3306 should stay accessible only inside the Swarm overlay

> **Note:** These are the exact versions used during development. Newer releases, such as newer Docker or Docker Compose versions, may work but aren't verified.

## Google Cloud Platform (GCP) Setup

```
(Work-In-Progress)
```

## Installation Setup

```
(Work-In-Progress)
```
