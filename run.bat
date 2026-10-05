@echo off
REM Start RELAY on http://localhost:8000  (offline mock unless RELAY_PROVIDER is set)
cd /d "%~dp0"
python -m uvicorn relay.main:app --host 0.0.0.0 --port 8000
