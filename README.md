# Jambvant WhatsApp Audio ChatBot

This repository contains an n8n workflow and a small UI prototype for a WhatsApp-based audio chatbot focused on Hindi audio interactions.

Structure:
- `n8n/` — n8n workflow export & documentation
  - `jambvant_n8n_workflow.json` — n8n workflow (import into n8n)
  - `jambvant_n8n_workflow.md` — node-by-node guide and configuration
- `ui/` — small prototype client for recording audio (`index.html`)

Quick start:
1. Import `n8n/jambvant_n8n_workflow.json` into your n8n instance (Workflows → Import).
2. Configure credentials and environment variables for WhatsApp, Google Cloud, DeepL, OpenAI, and PostgreSQL in n8n.
3. Use the UI prototype to capture sample audio and integrate upload to your backend to simulate incoming WhatsApp messages.

If you want, I can:
- Validate the JSON structure for n8n compatibility.
- Wire credential placeholders to n8n credential objects in the exported JSON.
- Add a small backend example (Node/Express) to accept the recorded audio and forward to WhatsApp media endpoint.

Production n8n
 - **URL:** https://n8n.srv1135069.hstgr.cloud/
 - **Important:** The repository's `deploy/docker-compose.yml` previously defined an `n8n` service. That service has been disabled in the repository to avoid accidentally starting a second n8n instance since n8n is already running in production at the URL above. Do not re-enable the service unless you intentionally want a separate instance.
 - **Data location (production):** n8n data is persisted by Docker on the host in the `n8n_data` volume (e.g. `/var/lib/docker/volumes/n8n_data/_data`).

If you want a local/dev instance instead of the production instance, I can:
 - Add a `docker-compose.dev.yml` with a namespaced `n8n_dev` service and separate volumes/ports, or
 - Provide step-by-step instructions to run a local workflow import into your remote n8n instance.
