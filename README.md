# Minecraft Server – Docker Setup

## Table of Contents

1. [About this Repository](#about-this-repository)
2. [Quickstart](#quickstart)
3. [Usage](#usage)
   - [Project Structure](#project-structure)
   - [Configuration](#configuration)
   - [Managing the Server](#managing-the-server)

---

## About this Repository

This repository contains everything needed to run a self-hosted Minecraft Java Edition server inside a Docker container. The setup is designed to be simple, portable, and easy to maintain.

The binary lives inside the image, while all data that should persist across restarts is stored locally in the `data/` directory via a bind mount.

---

## Quickstart

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker Engine
- A Minecraft server `.jar` file placed in the root of this repository named `server.jar`

### Steps

```bash
# 1. Clone this repository
git clone https://github.com/TobiasMatthies/Minecraft-Server-setup
cd Minecraft-Server-setup

# 2. Prepare environment variables
cp .env.template .env

# 3. Build and start the server
docker compose up --build
```

The server will be reachable at `localhost:25565` (or your VM's IP address on port `25565`).

---

## Usage

### Project Structure

```
.
├── Dockerfile          # Image definition
├── docker-compose.yml  # Container orchestration
├── entrypoint.sh       # Initialization script (EULA, Java execution)
├── server.jar          # Minecraft server binary
├── .env.template       # Template for environment variables
└── data/               # Persistent data (generated on first run)
    ├── server.properties
    ├── world/
    └── logs/
```

The `data/` directory is automatically created and populated by the container. It is ignored by git to keep your repository clean.

---

### Configuration

**Minecraft server settings (`server.properties`)**

After the first start, Minecraft generates a `server.properties` file in the `data/` directory. You can edit this file to change server settings such as:

| Setting       | Default              | Description                                            |
| ------------- | -------------------- | ------------------------------------------------------ |
| `max-players` | `20`                 | Maximum number of concurrent players                   |
| `difficulty`  | `easy`               | Game difficulty (`peaceful`, `easy`, `normal`, `hard`) |
| `gamemode`    | `survival`           | Default game mode for new players                      |
| `motd`        | `A Minecraft Server` | Message shown in the server list                       |
| `pvp`         | `true`               | Whether players can damage each other                  |

After editing `server.properties`, restart the container for changes to take effect:

```bash
docker compose restart
```

**Memory allocation**

The server is configured with 2 GB minimum and 4 GB maximum RAM. These values are set in `entrypoint.sh`:

```bash
exec java -Xms2G -Xmx4G -jar /app/server.jar --nogui
```

To change them, modify `-Xmx` (maximum) and `-Xms` (minimum) and rebuild the image:

```bash
docker compose up --build
```

**Port**

The default Minecraft port is `25565`. If you want to run the server on a different external port, change the "SERVER_PORT" variable in your .env file

---

### Managing the Server

**View live logs**

```bash
docker compose logs -f
```

**Stop the server**

```bash
docker compose down
```

**Start the server in the background**

```bash
docker compose up -d
```

**Access the server console**

```bash
docker attach mc-server
```

To detach from the console without stopping the server, press `Ctrl+P` followed by `Ctrl+Q`.

**Back up world data**

All world data lives in the `data/` directory. To create a backup, simply copy this directory:

```bash
cp -r ./data ./data-backup-$(date +%Y%m%d)
```
