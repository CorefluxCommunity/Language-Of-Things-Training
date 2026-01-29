# LoT (Language of Things) Training

**Learn LoT - The SQL of Real-Time MQTT Data**

This repository contains a complete, interactive learning path for mastering LoT (Language of Things), a domain-specific language for real-time MQTT data processing with Coreflux.

## What is LoT?

LoT is a human-readable language for IoT automation that runs directly inside the Coreflux MQTT broker. Think of it as **SQL for real-time MQTT streams**:

| SQL | LoT |
|-----|-----|
| `SELECT * FROM users WHERE age > 18` | `ON TOPIC "sensors/+" IF PAYLOAD > 80 THEN...` |
| Queries static database tables | Processes live MQTT streams |
| Batch processing | Real-time processing |

## Quick Start

### 1. Install Prerequisites

- **Docker**: [Get Docker](https://docs.docker.com/get-docker/)
- **VS Code**: [Download VS Code](https://code.visualstudio.com/)
- **LoT Notebooks Extension**: Search "LoT Notebooks" in VS Code Extensions

### 2. Start the Coreflux Broker

```bash
# Using Docker Compose (recommended)
cd setup
docker-compose up -d

# Or using the platform script
# Linux/macOS:
./setup/install-docker.sh

# Windows (PowerShell):
.\setup\install-docker.ps1
```

### 3. Configure VS Code

1. Open Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
2. Run "LoT Notebook: Change Credentials"
3. Enter:
   - URL: `mqtt://localhost:1883`
   - Username: `root`
   - Password: `coreflux`

### 4. Start Learning

Open `index.lotnb` in VS Code and follow the learning path!

## Learning Path

### Beginner Level

| Tutorial | Description | File |
|----------|-------------|------|
| Timed Actions | `ON EVERY` triggers, timestamps, counters | [`01-basics/timed-actions.lotnb`](01-basics/timed-actions.lotnb) |
| Topic Actions | `ON TOPIC` events, payload handling | [`01-basics/topic-actions.lotnb`](01-basics/topic-actions.lotnb) |
| Conditional Logic | IF/ELSE statements, comparisons | [`02-logic/conditional-logic.lotnb`](02-logic/conditional-logic.lotnb) |

### Intermediate Level

| Tutorial | Description | File |
|----------|-------------|------|
| Basic Models | Model definitions, field types, triggers | [`03-models/basic-models.lotnb`](03-models/basic-models.lotnb) |
| Action Models | Publishing models from actions | [`03-models/action-models.lotnb`](03-models/action-models.lotnb) |
| Model Inheritance | Extending models with FROM | [`03-models/model-inheritance.lotnb`](03-models/model-inheritance.lotnb) |
| MQTT Bridge | Connecting different brokers | [`04-routes/mqtt-bridge.lotnb`](04-routes/mqtt-bridge.lotnb) |
| Database Routes | SQL database integration | [`04-routes/database-routes.lotnb`](04-routes/database-routes.lotnb) |
| REST API Routes | HTTP API integration | [`04-routes/rest-api-routes.lotnb`](04-routes/rest-api-routes.lotnb) |
| Python Integration | CALL PYTHON for complex logic | [`05-python/simple-python.lotnb`](05-python/simple-python.lotnb) |

### Advanced Level

| Tutorial | Description | File |
|----------|-------------|------|
| Advanced Python | ML, statistics, external libraries | [`05-python/advanced-python.lotnb`](05-python/advanced-python.lotnb) |
| Mapping vs Events | Route architecture patterns | [`06-advanced/mapping-vs-events.lotnb`](06-advanced/mapping-vs-events.lotnb) |

## Project Structure

```
Training/
├── index.lotnb                    # Start here!
├── LoT-Complete-Documentation.md  # Full reference guide
├── .broker                        # Broker connection config
├── 01-basics/                     # Beginner tutorials
├── 02-logic/                      # Conditional logic
├── 03-models/                     # Data modeling
├── 04-routes/                     # System integration
├── 05-python/                     # Python integration
├── 06-advanced/                   # Advanced patterns
└── setup/                         # Installation scripts
    ├── docker-compose.yml
    ├── install-docker.sh          # Linux/macOS
    └── install-docker.ps1         # Windows
```

## What You'll Learn

By completing this training, you will:

- Create real-time data processing pipelines
- Build industrial IoT monitoring systems
- Integrate with databases, APIs, and other brokers
- Use Python for complex calculations and ML
- Design scalable automation architectures

## Key LoT Concepts

### Actions
Event-driven logic triggered by time or MQTT topics:
```lot
DEFINE ACTION TemperatureMonitor
ON TOPIC "sensors/+/temperature" DO
    IF PAYLOAD > 80 THEN
        PUBLISH TOPIC "alarms/high-temp" WITH PAYLOAD
```

### Models
Data schemas that structure MQTT messages:
```lot
DEFINE MODEL SensorReading WITH TOPIC "sensors/formatted/+"
    ADD STRING "sensor_id" WITH TOPIC POSITION 2
    ADD DOUBLE "value" WITH TOPIC "sensors/raw/+" AS TRIGGER
    ADD STRING "timestamp" WITH TIMESTAMP "UTC"
```

### Routes
Connections to external systems:
```lot
DEFINE ROUTE DatabaseStorage WITH TYPE POSTGRESQL
    ADD SQL_CONFIG
        WITH SERVER "localhost"
        WITH DATABASE "iot_data"
    ADD EVENT StoreSensorData
        WITH QUERY "INSERT INTO readings..."
        WITH SOURCE_TOPIC "sensors/+/data"
```

## Using LoT Notebooks

The `.lotnb` files are interactive notebooks that combine:
- **Markdown cells**: Explanations and documentation
- **LoT code cells**: Executable LoT definitions

When you run a LoT cell:
1. The code is sent to your connected Coreflux broker
2. The broker compiles and registers the definition
3. You see success/error feedback immediately

## Connection Details

| Setting | Default Value |
|---------|---------------|
| Host | localhost |
| Port | 1883 |
| Username | root |
| Password | coreflux |

> **Important**: Change the default password in production!

## Resources

- [Coreflux Documentation](https://docs.coreflux.org)
- [LoT Notebooks Extension](https://marketplace.visualstudio.com/items?itemName=Coreflux.vscode-lot-notebooks)
- [Community Discord](https://discord.com/invite/A3pPrptNMm)
- [GitHub Examples](https://github.com/CorefluxCommunity)

## License

This training material is provided for educational purposes. See the Coreflux website for licensing information about the Coreflux MQTT Broker.

---

**Ready to start? Open [`index.lotnb`](index.lotnb) and begin your LoT journey!**
