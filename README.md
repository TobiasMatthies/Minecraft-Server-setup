# Minecraft Server – Docker Setup

## Table of Contents

1. [About this Repository](#about-this-repository)
2. [Quickstart](#quickstart)
3. [Usage](#usage)
   - [Project Structure](#project-structure)
   - [Local Setup](#local-setup)
   - [VM Setup](#vm-setup)
   - [Configuration](#configuration)
   - [Managing the Server](#managing-the-server)

---

## About this Repository

This repository contains everything needed to run a self-hosted Minecraft Java Edition server inside a Docker container. The setup is designed to be simple, portable, and easy to maintain.

The repository contains the following key files:

- `Dockerfile` – defines the container image, including the Java runtime and the server binary
- `docker-compose.yml` – defines how the container is started, including ports, volumes, and restart behavior
- `server.jar` – the Minecraft server binary
- `data/` – a directory that is mounted into the container and holds all generated server files (world data, configs, logs)

The goal of this setup is to keep the server binary and the generated server data cleanly separated: the binary lives inside the image, while all data that should persist across restarts is stored locally in the `data/` directory via a bind mount.

---

## Quickstart

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (local) or Docker Engine (VM)
- A Minecraft server `.jar` file placed in the root of this repository named `server.jar`

### Steps

```bash
# 1. Clone this repository
git clone <your-repo-url>
cd <repo-folder>

# 2. Create the data directory and accept the Minecraft EULA
mkdir data
echo "eula=true" > data/eula.txt

# 3. Build and start the server
docker compose up --build
```

The server will be reachable at `localhost:25565` (or your VM's IP address on port `25565`).

---

## Usage

### Project Structure

```
.
├── Dockerfile
├── docker-compose.yml
├── server.jar
└── data/               # generated on first run, persisted via bind mount
    ├── eula.txt
    ├── server.properties
    ├── world/
    └── logs/
```

The `data/` directory is intentionally not committed to version control. It will be created manually and populated automatically by Minecraft on first start.

---

### Local Setup

**1. Install Docker Desktop**

Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop/) for your operating system. Start it and wait until the Docker daemon is running (indicated by the whale icon in the menu bar on macOS).

**2. Prepare the data directory**

```bash
mkdir data
echo "eula=true" > data/eula.txt
```

Minecraft requires you to accept its End User License Agreement before starting. Without this file the server will refuse to launch.

**3. Build the image and start the container**

```bash
docker compose up --build
```

The `--build` flag forces Docker to rebuild the image. You only need this on the first start or after modifying the `Dockerfile`. For subsequent starts you can use:

```bash
docker compose up
```

**4. Connect to the server**

Open Minecraft Java Edition, go to Multiplayer, and add a server with the address `localhost` (or `127.0.0.1`). The port is `25565` by default.

---

### VM Setup

**1. Install Docker Engine on the VM**

On Ubuntu-based VMs:

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker
```

Verify the installation:

```bash
docker --version
docker compose version
```

**2. Transfer the project files to the VM**

Clone the repository directly on the VM from GitHub and upload your server.jar in the project directory:

```bash
scp -r server.jar user@your-vm-ip:~/Minecraft-server-setup/
```

Or upload a copy of your local folder:

```bash
scp -r ./ user@your-vm-ip:~/minecraft-server
```

**3. Open port 25565 in your firewall**

This step depends on your cloud provider. Examples:

- **Hetzner**: Add a firewall rule for TCP port 25565 inbound in the Hetzner Cloud Console
- **AWS**: Add an inbound rule for TCP port 25565 to the EC2 instance's Security Group
- **DigitalOcean**: Add a firewall rule in the Networking section of the control panel

On the VM itself, if `ufw` is active:

```bash
sudo ufw allow 25565/tcp
```

**4. Start the server**

```bash
cd ~/minecraft-server
mkdir data
echo "eula=true" > data/eula.txt
docker compose up --build -d
```

The `-d` flag runs the container in detached mode (in the background).

**5. Connect to the server**

In Minecraft, add a server with the address of your VM's public IP. The port is `25565`.

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

The server is configured with 2 GB minimum and 4 GB maximum RAM. These values are set in the `ENTRYPOINT` line of the `Dockerfile`:

```dockerfile
ENTRYPOINT ["java", "-Xmx4G", "-Xms2G", "-jar", "/serverfile/server.jar", "nogui"]
```

To change them, modify `-Xmx` (maximum) and `-Xms` (minimum) and rebuild the image:

```bash
docker compose up --build
```

As a rule of thumb: allocate roughly 1 GB per 5–10 concurrent players, plus a base of ~1 GB for the server process itself.

**Port**

The default Minecraft port is `25565`. If you want to run the server on a different external port, change the left side of the port mapping in `docker-compose.yml`:

```yaml
ports:
  - '19132:25565' # server is now reachable externally on port 19132
```

The right side (`25565`) is the internal container port and should not be changed.

**Java version**

The `Dockerfile` uses `eclipse-temurin:25` as the base image, which provides Java 25. If a future Minecraft version requires a different Java version, update the first line of the `Dockerfile` accordingly:

```dockerfile
FROM eclipse-temurin:25   # change 25 to the required version
```

You can find available versions on [Docker Hub](https://hub.docker.com/_/eclipse-temurin/tags).

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

**Rebuild the image after changes to the Dockerfile**

```bash
docker compose up --build
```

**Back up world data**

All world data lives in the `data/` directory. To create a backup, simply copy this directory:

```bash
cp -r ./data ./data-backup-$(date +%Y%m%d)
```

It is recommended to stop the server before creating a backup to avoid data corruption:

```bash
docker compose down
cp -r ./data ./data-backup-$(date +%Y%m%d)
docker compose up -d
```
