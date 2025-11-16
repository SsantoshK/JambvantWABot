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
