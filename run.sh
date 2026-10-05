#!/usr/bin/env sh
# Start RELAY on http://localhost:8000  (offline mock unless RELAY_PROVIDER is set)
cd "$(dirname "$0")"
python3 -m uvicorn relay.main:app --host 0.0.0.0 --port "${PORT:-8000}"
