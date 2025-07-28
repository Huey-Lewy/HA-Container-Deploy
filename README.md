# About HA-Container-Deploy

**HA Container Deploy** automates the high-availability deployment of a containerized web application and database on Google Cloud. It sets up multiple app replicas behind a load balancer, utilizes LVM-backed storage for the database, and includes scripts to provision and deploy the necessary infrastructure.

## Repository Layout (WIP)

```
├── app/            # Build web application image
│   ├── Dockerfile          # Docker build instructions for app
│   └── src/                # Application source code
│       ├── main.py                 # Entry point script
│       └── requirements.txt        # Python dependencies list
│
├── db/             # Database image and LVM config
│   ├── Dockerfile          # Docker build instructions for DB
│   ├── init.sql            # Initialize database schema
│   └── lvm/                # LVM setup scripts
│       └── create-volumes.sh       # Script to create LVM volumes
│
├── config/         # Load balancer and server configs
│   ├── haproxy/            # HAProxy configuration folder
│   │   └── haproxy.cfg             # HAProxy rules file
│   └── nginx/              # Nginx configuration folder
│       └── nginx.conf              # Nginx server block file
│
├── scripts/        # Automation and infrastructure scripts
│   ├── create-volumes.sh   # Create LVM volumes
│   ├── deploy.sh           # Deploy containers and services
│   ├── healthcheck.sh      # Check service health status
│   └── teardown.sh         # Tear down and clean up resources
│
├── .gitignore      # Define ignored files for Git
├── LICENSE         # Project license file
├── README.md       # Project overview and setup instructions
├── docker-compose.yml      # Define and compose containers
└── .env.example            # Sample environment variable definitions
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

> **Note:** We tested these versions during development. <br> Newer releases may work but aren't verified.

## Google Cloud Platform (GCP) Setup

```
(Work-In-Progress)
```

## Installation Setup

```
(Work-In-Progress)
```