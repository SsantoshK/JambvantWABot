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

Dev: running a local/dev instance

- Use the included `deploy/docker-compose.dev.yml` to run an isolated dev environment (separate volumes and ports).

  From `deploy/` run:
  ```bash
  docker compose -f docker-compose.dev.yml up --build -d
  # n8n dev UI will be available at http://localhost:5679 (or use the host IP)
  ```

- To import the workflow into n8n (UI):
  1. Open your n8n instance (remote or local) and go to Workflows → Import.
  2. Upload `n8n/jambvant_n8n_workflow.json`.

- Environment variables used by the workflow (ensure they are configured in n8n credentials or env):
  - `GOOGLE_API_KEY` — Google Cloud Speech and TTS
  - `GCS_BUCKET_NAME` — Google Cloud Storage bucket for audio
  - `WHATSAPP_PHONE_ID` — WhatsApp Cloud API phone ID

If you'd like, I can also wire these to n8n credential objects in the exported JSON (replace `{{ $env.* }}` with credential references) or provide sample `.env` values for the dev compose file.
