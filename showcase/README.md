# LoT Showcase Notebooks

Three ready-to-run notebooks that show **every LoT entity type** in short, readable cells.
Each code cell has a plain-language markdown cell before it.

| Notebook | Theme | Highlights |
|---|---|---|
| [01-flights-tracker.lotnb](01-flights-tracker.lotnb) | Airport operations | Python, timer, topic and callable actions, models with inheritance, REST API server, file storage, MQTT bridge, rules, theme, panel, AI agent |
| [02-bottling-line.lotnb](02-bottling-line.lotnb) | Factory line (IIoT) | Modbus server and client, OPC UA server and client, OEE with Python, model inheritance, **Things** (preview), rules, dashboard, maintenance agent; optional PostgreSQL, Kafka and Siemens S7 |
| [03-smart-building.lotnb](03-smart-building.lotnb) | Smart building | Unified namespace with wildcard actions, comfort and energy alarms, Modbus gateway for a BMS, REST webhook, two dashboards, two cooperating agents; optional weather API, BACnet and email |

## How to run

1. Start a Coreflux broker (see [00-setup](../00-setup)) and open a notebook in VS Code with the LoT Notebooks extension.
2. Run the cells top to bottom, or deploy the whole notebook.

**Core mode needs nothing but the broker.** Every notebook simulates its own data.

- Cells under a heading marked **`[needs: X]`** are optional and need service *X* (Ollama, PostgreSQL, Kafka, a PLC, an SMTP server, internet…).
- Cells marked **`(preview)`** use `DEFINE THING`, which ships with ENG-421. Each has a fallback cell that works on today's broker; deploy one or the other.
- Agents are defined **without a running LLM**: they appear in Coreflux Hub and only call the model when asked. Install [Ollama](https://ollama.com) and `ollama pull llama3.2` to talk to them.
- Agents act as their `DEFAULT_USER`. Create those users first, for example `-addUser flights-viewer <password>`.

Port numbers used by the core cells: REST 8085 (flights) and 8086 (building), Modbus 5020 (line) and 5021 (building), OPC UA 4841.
