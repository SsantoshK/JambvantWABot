#!/usr/bin/env bash
set -euo pipefail

DOMAIN="jambvant.com"
TARGET_IPV6="2a02:4780:12:a7ff::1"
COMPOSE_FILE="/root/JambvantWABot/deploy/docker-compose.prod.yml"
LOGFILE="/root/JambvantWABot/deploy/letsencrypt/watch_dns_and_tail.log"

mkdir -p "$(dirname "$LOGFILE")"

echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") Starting DNS watcher for $DOMAIN, looking for AAAA $TARGET_IPV6" >> "$LOGFILE"

echo "Using resolvers: system default, 1.1.1.1, 8.8.8.8" >> "$LOGFILE"

while true; do
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  aaaa_system=$(dig +short AAAA "$DOMAIN" | tr -d '\n' || true)
  aaaa_cf=$(dig +short AAAA "$DOMAIN" @1.1.1.1 | tr -d '\n' || true)
  aaaa_gg=$(dig +short AAAA "$DOMAIN" @8.8.8.8 | tr -d '\n' || true)

  echo "$now system:$aaaa_system cloudflare:$aaaa_cf google:$aaaa_gg" >> "$LOGFILE"

  if [ "$aaaa_system" = "$TARGET_IPV6" ] || [ "$aaaa_cf" = "$TARGET_IPV6" ] || [ "$aaaa_gg" = "$TARGET_IPV6" ]; then
    echo "$now AAAA matches target ($TARGET_IPV6). Starting Traefik logs tail." >> "$LOGFILE"
    echo "--- Traefik logs (follow) ---" >> "$LOGFILE"
    docker compose -f "$COMPOSE_FILE" logs -f traefik >> "$LOGFILE" 2>&1
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") Traefik logs process exited." >> "$LOGFILE"
    break
  fi

  sleep 120
done
