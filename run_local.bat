@echo off
REM Start RELAY with free local AI models (Ollama). No API keys, no internet needed after setup.
REM   OLLAMA_MODEL         = the model the agents think with      (default qwen2.5:7b,  about 4.7 GB)
REM   OLLAMA_VISION_MODEL  = the model that looks at photos        (default qwen2.5vl:7b, about 6 GB)
REM Slow or 8 GB laptop: set OLLAMA_MODEL=qwen2.5:3b and set OLLAMA_VISION_MODEL=qwen2.5vl:3b first.
cd /d "%~dp0"
if "%OLLAMA_MODEL%"=="" set OLLAMA_MODEL=qwen2.5:7b
if "%OLLAMA_VISION_MODEL%"=="" set OLLAMA_VISION_MODEL=qwen2.5vl:7b
set RELAY_PROVIDER=ollama
set RELAY_VISION_PROVIDER=ollama
where ollama >nul 2>nul || (echo Ollama is not installed. Get it free from https://ollama.com/download then run this again. & pause & exit /b 1)
ollama list | findstr /i /c:"%OLLAMA_MODEL%" >nul || (echo Downloading %OLLAMA_MODEL% once... & ollama pull %OLLAMA_MODEL%)
ollama list | findstr /i /c:"%OLLAMA_VISION_MODEL%" >nul || (echo Downloading photo model %OLLAMA_VISION_MODEL% once... & ollama pull %OLLAMA_VISION_MODEL%)
echo Warming up %OLLAMA_MODEL% ...
ollama run %OLLAMA_MODEL% "Reply with OK" >nul
echo.
echo RELAY is using local models: %OLLAMA_MODEL% (agents) and %OLLAMA_VISION_MODEL% (photos).
echo Each step takes a few seconds to a minute on a laptop.
python -m uvicorn relay.main:app --host 0.0.0.0 --port 8000
