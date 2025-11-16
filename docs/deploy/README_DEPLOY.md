<!-- Moved from deploy/README_DEPLOY.md -->
# Deploying n8n + PostgreSQL on Hostinger VPS (recommended)

This guide shows a straightforward way to run `n8n` with `Postgres` on a Hostinger VPS using Docker Compose. It assumes you have a Hostinger VPS (not shared hosting), SSH access, and a domain you can point to the server.

1) Prepare the VPS

- SSH into the server (PowerShell example):

```pwsh
ssh username@your_vps_ip
```

- Update and install Docker + docker-compose (Ubuntu example):

```bash
sudo apt update && sudo apt upgrade -y
# Deploying n8n + PostgreSQL on Hostinger VPS (detailed)

This document walks through what to purchase on Hostinger, how to provision a VPS, and a step-by-step deployment of n8n, PostgreSQL, and a simple app to provide a WhatsApp in-app user experience. Example domain: `jambvant.com`.

## Summary

We will provision and configure:
- Hostinger VPS (Docker + n8n)
- PostgreSQL (self-hosted in Docker) with schema for users and message logs
- n8n workflow (import `n8n/jambvant_n8n_workflow.json`)
- Optional reverse proxy with TLS (Traefik or nginx + Certbot)
- Adminer for quick DB UI and a small UI prototype that records Hindi audio

## Purchase checklist (Hostinger)

- VPS (VPS or Cloud): choose a plan with at least 2 vCPU and 4 GB RAM for production. For initial testing a 1 vCPU / 2 GB RAM plan may suffice. Recommended: VPS 2 or higher.
- Domain: `jambvant.com` (register via Hostinger or an external registrar). You will point an A record to your VPS public IP.
- Optional: managed database (Hostinger) if you prefer not to self-host Postgres. This guide assumes a local Postgres container.
- Optional: object storage (Google Cloud Storage) for hosting generated audio files. You can also use Hostinger storage or a public bucket — choose what fits your architecture/privacy/cost needs.

## Before you begin

- Ensure you have SSH access to the VPS and a user with sudo privileges.
- Point DNS `A` record for `jambvant.com` to the VPS public IP. DNS changes can take minutes to hours to propagate.

## Step 1 — SSH into the VPS (from your Windows machine using PowerShell)

```pwsh
ssh username@your_vps_ip
```

## Step 2 — Install Docker & Docker Compose (Ubuntu example)

```bash
sudo apt update && sudo apt upgrade -y
# Install curl / common tools
sudo apt install -y curl apt-transport-https ca-certificates gnupg lsb-release
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
# Install docker-compose plugin (or the python-based binary)
sudo apt install -y docker-compose
# Add your user to the docker group (logout/login required)
sudo usermod -aG docker $USER
```

## Step 3 — Clone repo and prepare environment

```bash
git clone https://github.com/SsantoshK/JambvantWABot.git
cd JambvantWABot/deploy
cp .env.example .env
# Edit .env and set strong passwords and WEBHOOK_URL=https://jambvant.com
```

Edit `.env` values on the VPS:
- `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` — use strong credentials.
- `N8N_BASIC_AUTH_USER` / `N8N_BASIC_AUTH_PASSWORD` — protect the n8n UI.
- `WEBHOOK_URL=https://jambvant.com` and `VUE_APP_URL_BASE_API` as needed.

## Step 4 — Start the stack

```bash
docker compose up -d
```

This starts `postgres`, `n8n`, and `adminer` per `deploy/docker-compose.yml`.

## Step 5 — Run with TLS (recommended)

For production, run n8n behind a reverse proxy with TLS:
- Traefik: works well with Docker and automates Let's Encrypt certs. Create a `docker-compose.prod.yml` with a `traefik` service and add labels to `n8n`.
- nginx + Certbot: configure nginx as a reverse proxy and use Certbot to obtain certificates.

If you'd like, I can produce a `docker-compose.prod.yml` with Traefik and example labels.

## Step 6 — Initialize the database

Run the schema to create `users`, `user_facts`, and `message_logs`:

```bash
docker compose exec -e PGPASSWORD=${POSTGRES_PASSWORD} postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f /workspace/deploy/schema.sql
```

If the `-f` path doesn't work inside the container, copy `deploy/schema.sql` into the container or run psql from the host.

## Step 7 — Import n8n workflow and set credentials

- Open n8n UI (http://your_vps_ip:5678 or https://jambvant.com if behind proxy).
- Import `n8n/jambvant_n8n_workflow.json` (Workflows → Import).
- Configure credentials in n8n for:
  - WhatsApp Business Cloud: Phone Number ID, Access Token
  - Google Cloud: API Key or service account for STT/TTS and GCS
  - DeepL: API Key
  - OpenAI: API Key
  - PostgreSQL: host `postgres`, port `5432`, user/db from `.env`

Important: confirm the webhook path in the workflow is `jambvant-voice-bot` and set `WEBHOOK_URL=https://jambvant.com` so the full webhook becomes `https://jambvant.com/webhook/jambvant-voice-bot`.

## Step 8 — WhatsApp Business setup & webhook registration

1. Create a Meta for Developers app and a WhatsApp Business Account (WABA) if you haven't already.
2. Add the phone number and obtain the `PHONE_NUMBER_ID` and long-lived `ACCESS_TOKEN`.
3. In the WhatsApp Business Cloud settings, register the callback webhook URL: `https://jambvant.com/webhook/jambvant-voice-bot` and verify the token.
4. Subscribe to messages and media events so your webhook receives incoming audio messages.

## Step 9 — App/UI integration and WhatsApp in-app UX

Primary UX model:
- User records and sends audio from within WhatsApp (native app).
- WhatsApp delivers a webhook with media id to n8n.
- n8n downloads media, performs STT (Hindi), translates, queries stored user context, calls the LLM, translates response back to Hindi, creates TTS audio, uploads to storage, and sends the audio back to the user with interactive buttons for feedback.

Design tips for good in-app experience:
- Normalize phone numbers to E.164 (e.g. `+919876543210`) and store in `users`.
- Keep messages short and actionable. Use quick reply buttons for follow-ups.
- Use interactive messages and templates for outbound-initiated messages (Meta requires template messages for business-initiated conversations).
- Host TTS audio on a public URL (GCS or Hostinger storage) and provide that URL in the WhatsApp audio message.

Testing flow (quick):
1. From a test phone, send a voice note to your business account.
2. Confirm n8n received the webhook and started the workflow (n8n execution log).
3. Check `message_logs` in Postgres to see the recorded input and output.
4. Verify the audio response plays correctly in WhatsApp and buttons appear as expected.

## Step 10 — Monitoring, backups and maintenance

- Logs: use `docker compose logs -f n8n` and `docker compose logs -f postgres`.
- Backups: schedule `pg_dump` daily and store backups off-site.
- Health checks: consider a small cron job or monitoring tool to verify services are healthy.

## Step 11 — Security and production hardening

- Use a strong `.env` and avoid committing secrets.
- Run n8n behind a reverse proxy and enable `N8N_BASIC_AUTH`.
- Limit network exposure and use firewall rules if appropriate.

## Step 12 — Costs & limitations

- WhatsApp Business Cloud: per-message pricing and templates for business-initiated messages.
- Google STT/TTS and DeepL: per-use costs. Monitor usage and set alerts.

## Next steps I can help with

- Create a `docker-compose.prod.yml` with Traefik and Let's Encrypt labels.
- Add a small Node/Express test endpoint to forward UI-recorded audio to the webhook for local testing and QA.
- Perform JSON validation and an n8n import test (requires access or local n8n instance).

If you want, I can update `deploy/.env.example` to set `WEBHOOK_URL=https://jambvant.com` and generate the Traefik `docker-compose.prod.yml`. Also tell me whether you prefer Google Cloud Storage (recommended) or Hostinger storage for TTS audio hosting.
