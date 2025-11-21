#!/usr/bin/env bash
set -euo pipefail
DOMAIN="jambvant.com"
TARGET_IPV6="2a02:4780:12:a7ff::1"
LOGFILE="/root/JambvantWABot/deploy/letsencrypt/dns_periodic_check.log"
MAX_ITER=15
INTERVAL=120

mkdir -p "$(dirname "$LOGFILE")"
echo "$(date -u +'%Y-%m-%dT%H:%M:%SZ') Starting periodic DNS check for $DOMAIN (target $TARGET_IPV6), max $MAX_ITER iterations every $INTERVALs" >> "$LOGFILE"

for i in $(seq 1 $MAX_ITER); do
  now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  aaaa_sys=$(dig +short AAAA "$DOMAIN" | tr -d '\n' || true)
  aaaa_cf=$(dig +short AAAA "$DOMAIN" @1.1.1.1 | tr -d '\n' || true)
  aaaa_gg=$(dig +short AAAA "$DOMAIN" @8.8.8.8 | tr -d '\n' || true)
  echo "$now iter=$i system:$aaaa_sys cloudflare:$aaaa_cf google:$aaaa_gg" >> "$LOGFILE"

  if [ "$aaaa_sys" = "$TARGET_IPV6" ] || [ "$aaaa_cf" = "$TARGET_IPV6" ] || [ "$aaaa_gg" = "$TARGET_IPV6" ]; then
    echo "$now AAAA matches target ($TARGET_IPV6) on iteration $i" >> "$LOGFILE"
    exit 0
  fi

  if [ $i -lt $MAX_ITER ]; then
    sleep $INTERVAL
  fi
done

echo "$(date -u +'%Y-%m-%dT%H:%M:%SZ') Completed $MAX_ITER iterations without match" >> "$LOGFILE"
exit 0
