# LoT Training Environment Setup

This folder contains everything needed to set up a complete LoT training environment with simulation infrastructure.

---

> **IMPORTANT - Free Tier Resource Limits**
>
> The free version of Coreflux has resource limits:
> - **Routes**: 2 maximum
> - **Actions**: 12 maximum
> - **Models**: 40 maximum
>
> Delete unused resources before creating new ones during exercises.

---

## What's Included

| Service | Port | Description |
|---------|------|-------------|
| **Coreflux MQTT** | 1883 | Primary LoT broker with LoT runtime |
| **PostgreSQL** | 5432 | Database for route exercises |
| **OPC UA Simulator** | 4840 | Factory simulation with industrial I/Os |
| **Mosquitto** | 1884 | Secondary MQTT broker for bridge exercises |
| **Adminer** | 8080 | Database management UI |

## Prerequisites

- **Docker Desktop**: Install from https://docs.docker.com/get-docker/
- **VS Code**: Recommended IDE
- **LoT Notebooks Extension**: Search "LoT Notebooks" in VS Code extensions

## Quick Start

### 1. Start All Services

```bash
# Navigate to the setup folder
cd setup

# Start all services
docker-compose up -d

# Check all services are running
docker-compose ps
```

Expected output:
```
NAME                      STATUS
coreflux_broker          Up (healthy)
lot_postgres             Up (healthy)
opcua_factory_simulator  Up
mosquitto_bridge         Up
lot_adminer              Up
```

### 2. Verify Environment

Open the verification notebook: `../00-setup/verify-environment.lotnb`

### 3. Configure VS Code Extension

1. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
2. Type "LoT Notebook: Change Credentials"
3. Enter:
   - URL: `mqtt://localhost:1883`
   - Username: `admin`
   - Password: `coreflux`

### 4. Start Learning

Open `../index.lotnb` and follow the learning path.

---

## Service Details

### Coreflux MQTT Broker (Primary)

The main LoT broker with full LoT runtime.

| Setting | Value |
|---------|-------|
| MQTT Port | 1883 |
| WebSocket Port | 5000 |
| MQTT TLS Port | 8883 |
| Username | `admin` |
| Password | `coreflux` |

**Connection string**: `mqtt://localhost:1883`

### PostgreSQL Database

Pre-configured database with training tables and sample data.

| Setting | Value |
|---------|-------|
| Host | localhost |
| Port | 5432 |
| Database | `lot_training` |
| Username | `lot_user` |
| Password | `lot_training_pass` |

**Available Tables:**
- `production_records` - Production batch tracking
- `sensor_readings` - Time-series sensor data
- `quality_results` - Quality control results
- `traceability` - Part/component tracking
- `equipment_status` - Equipment state tracking
- `alarms` - Alarm history

**Access via Adminer**: http://localhost:8080

### OPC UA Factory Simulator

Microsoft's industrial OPC UA simulator with realistic data patterns.

| Setting | Value |
|---------|-------|
| Endpoint | `opc.tcp://localhost:4840` |
| Authentication | None (auto-accept) |

**Simulated Nodes:**
| Node ID | Type | Description |
|---------|------|-------------|
| `ns=2;s=SlowUInt1` | UINT | Slow counter (5s) |
| `ns=2;s=FastUInt1` | UINT | Fast counter (1s) |
| `ns=2;s=RandomSignedInt32` | INT | Random values |
| `ns=2;s=AlternatingBoolean` | BOOL | Toggle (1s) |
| `ns=2;s=PositiveTrendData` | DOUBLE | Trending up |
| `ns=2;s=NegativeTrendData` | DOUBLE | Trending down |
| `ns=2;s=SpikeData` | DOUBLE | Spike pattern |
| `ns=2;s=DipData` | DOUBLE | Dip pattern |

### Mosquitto MQTT Broker (Secondary)

Secondary broker for testing MQTT bridge routes.

| Setting | Value |
|---------|-------|
| MQTT Port | 1884 (external) |
| WebSocket Port | 9001 |
| Authentication | None (anonymous) |

**Test with:**
```bash
mosquitto_sub -h localhost -p 1884 -t "#" -v
mosquitto_pub -h localhost -p 1884 -t "test" -m "hello"
```

### Adminer (Database UI)

Web-based database management.

| Setting | Value |
|---------|-------|
| URL | http://localhost:8080 |
| System | PostgreSQL |
| Server | `postgres` |

---

## Public Services (No Setup Required)

These external services are used in tutorials:

| Service | URL | Purpose |
|---------|-----|---------|
| **Coreflux Cloud** | `iot.coreflux.cloud:1883` | Cloud bridge demos |
| **JSONPlaceholder** | `jsonplaceholder.typicode.com` | REST API testing |
| **ReqRes** | `reqres.in/api` | User management API |
| **Open-Meteo** | `api.open-meteo.com` | Weather data |

> **Note:** All messages on the public Coreflux broker are visible to everyone!

---

## Docker Commands

### Starting Services

```bash
# Start all services
docker-compose up -d

# Start specific services
docker-compose up -d coreflux postgres

# Start with logs visible
docker-compose up
```

### Stopping Services

```bash
# Stop all services (keeps data)
docker-compose down

# Stop and remove all data
docker-compose down -v
```

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f coreflux
docker-compose logs -f postgres
docker-compose logs -f opcua_simulator
```

### Service Status

```bash
# Check running services
docker-compose ps

# Check resource usage
docker-compose top
```

### Restarting Services

```bash
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart coreflux
docker-compose restart postgres
```

---

## Troubleshooting

### Docker Not Found

Install Docker Desktop from https://docs.docker.com/get-docker/

### Services Won't Start

```bash
# Check logs for errors
docker-compose logs

# Rebuild if needed
docker-compose build --no-cache
docker-compose up -d
```

### Port Conflicts

Check if ports are already in use:

**Windows:**
```powershell
netstat -ano | findstr "1883 5432 4840 1884 8080"
```

**Linux/macOS:**
```bash
lsof -i :1883 -i :5432 -i :4840 -i :1884 -i :8080
```

### Database Connection Failed

1. Ensure PostgreSQL is running: `docker-compose ps lot_postgres`
2. Check logs: `docker-compose logs postgres`
3. Try Adminer: http://localhost:8080
4. Verify credentials match `.env.example`

### OPC UA Simulator Not Responding

The simulator takes 20+ seconds to start:
```bash
docker-compose logs opcua_simulator
```

Wait until you see "Server started" in the logs.

### Reset Everything

```bash
# Stop, remove containers and volumes
docker-compose down -v

# Start fresh
docker-compose up -d
```

---

## Environment Configuration

Copy `.env.example` to `.env` to customize settings:

```bash
cp .env.example .env
```

Edit `.env` to change database credentials, ports, etc.

---

## File Structure

```
setup/
├── docker-compose.yml      # All service definitions
├── .env.example            # Environment template
├── README.md               # This file
├── install-docker.sh       # Linux/macOS installer
├── install-docker.ps1      # Windows installer
├── db-init/
│   └── init.sql            # Database schema & sample data
└── mosquitto/
    └── config/
        └── mosquitto.conf  # Mosquitto configuration
```

---

## Next Steps

1. Verify environment with `../00-setup/verify-environment.lotnb`
2. Open `../index.lotnb` to start the training
3. Follow the progressive learning path
4. Complete exercises in each tutorial
5. Experiment with your own LoT code

---

## Resources

- [Coreflux Documentation](https://docs.coreflux.org)
- [LoT Notebooks Extension](https://marketplace.visualstudio.com/items?itemName=Coreflux.vscode-lot-notebooks)
- [Coreflux Community Discord](https://discord.com/invite/A3pPrptNMm)
- [GitHub Examples](https://github.com/CorefluxCommunity)
