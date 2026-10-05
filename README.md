# RELAY — Proof-of-Resolution Maintenance Agent

> **A repair isn't finished when someone says so. It's finished when the evidence agrees.**

RELAY is an agentic AI maintenance system for hostels and campus housing. A team of three AI agents diagnoses each fault, plans the repair and checks the result. A complaint is closed only when the measured evidence, the verifier agent and the resident all agree that the original problem is gone.

**Track:** Agentic AI, Industry-Specific Copilot (Facilities / Maintenance)
**Version:** 1.8

---

## Contents

- [The problem](#the-problem)
- [What RELAY does](#what-relay-does)
- [Quick start (no API key needed)](#quick-start-no-api-key-needed)
- [Running with a live AI model](#running-with-a-live-ai-model)
- [Demo walkthrough](#demo-walkthrough)
- [How it works](#how-it-works)
- [Safety and responsible design](#safety-and-responsible-design)
- [Tech stack](#tech-stack)
- [Testing](#testing)
- [Project layout](#project-layout)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [What's real and what's simulated](#whats-real-and-whats-simulated)

---

## The problem

In most hostels, a broken AC or fan is reported in a register, over WhatsApp or by calling the warden. A technician visits, says "done", and the complaint is closed. Nobody checks whether the original problem is actually gone. Partial or wrong repairs are common, so the same fault returns days later as a brand-new complaint with no memory of what was already tried.

- **Residents** live with the same fault for days or weeks.
- **Wardens** can't tell which repairs worked or which units keep failing, and pay for repeat visits.
- **Technicians** get vague complaints with no history or manual guidance.

## What RELAY does

| Step | What happens |
|---|---|
| **Report** | A resident scans the QR sticker on the unit, describes the fault and optionally adds a photo. Duplicate reports join the open incident. |
| **Diagnose** | The diagnosis agent studies the unit's history, the service manual and similar past incidents, and names the likely cause with citations. Code checks every citation is real. |
| **Plan** | The planner agent picks the manual procedure, checks part stock, finds a qualified technician and estimates cost. |
| **Define "fixed"** | Before any work starts, RELAY writes the resolution criteria: exactly what must be true for this fault to count as fixed. |
| **Approve** | A policy engine recomputes cost and hazard. Electrical, gas, refrigerant or structural work, jobs above ₹1,500 and repeat attempts wait for the warden. |
| **Repair** | The technician follows the procedure on their phone and submits readings, the part used, a checklist, notes and a fresh photo. |
| **Verify** | Code checks the readings; the photo is checked for reuse, old timestamps and unrelated content; the verifier agent cross-checks everything; the resident confirms. |
| **Close or reopen** | Closed only when everything agrees. Otherwise RELAY asks for exactly the missing evidence, or reopens as a new attempt that starts from what already failed. |

The warden sees every agent step live and gets alerts for units that keep failing.

---

## Quick start (no API key needed)

RELAY ships with a built-in **offline demo agent**. It's a deterministic, rule-based reasoner that speaks the same protocol as the real models and calls the same tools. You can run the whole system with no key, no internet and no cost. The screens label it clearly as the offline mode.

**Requirements:** Python 3.10 or newer.

```bash
pip install -r requirements.txt
```

**Windows:** double-click `run.bat`, or run it from Command Prompt.
**macOS / Linux:** `./run.sh`

Open **http://localhost:8000**.

| Screen | URL | Demo sign-in |
|---|---|---|
| Home and QR codes | `/` | none |
| Resident report (phone) | `/r/q-ac304`, or scan a QR | none |
| Technician jobs (phone) | `/tech` | `ravi` / `1111` (HVAC), `suresh` / `2222` (electrical), `anil` / `3333` |
| Warden console | `/admin` | `warden` / `1234` |
| Printable QR stickers | `/labels` | none |

**Phones:** when RELAY starts, its window prints the address phones should use (for example `http://192.168.1.5:8000`). The QR codes always point there, never to `localhost`. Connect the phone to the same Wi-Fi and scan.

---

## Running with a live AI model

> **In our demo video, RELAY runs on the Groq API:** `openai/gpt-oss-120b` for the three agents and Llama 4 Scout for reading photos.
> You don't need a key to try RELAY, because the offline demo agent works out of the box. To use a real model as in the video, follow the steps below.

### Option A — Groq (used in the demo, free tier, no download)

1. Create a free account at **https://console.groq.com** and create an API key (**API Keys → Create API Key**).
2. In a terminal inside the project folder, run the commands for your system.

**Windows (Command Prompt)**
```bat
set RELAY_PROVIDER=groq
set GROQ_API_KEY=your_groq_key
set GROQ_MODEL=openai/gpt-oss-120b
python scripts\check_provider.py
run.bat
```

**Windows (PowerShell)**
```powershell
$env:RELAY_PROVIDER="groq"
$env:GROQ_API_KEY="your_groq_key"
$env:GROQ_MODEL="openai/gpt-oss-120b"
python scripts\check_provider.py
.\run.bat
```

**macOS / Linux**
```bash
export RELAY_PROVIDER=groq
export GROQ_API_KEY=your_groq_key
export GROQ_MODEL=openai/gpt-oss-120b
python scripts/check_provider.py
./run.sh
```

`check_provider.py` runs one sample incident through diagnosis and planning against the live model. It should end with **PASS**. The warden console then shows **"Agents: groq (openai/gpt-oss-120b) + groq vision"**.

Notes:
- Run `run.bat` / `run.sh` in the **same** terminal where you set the variables. A new terminal needs them set again.
- If a model is retired, RELAY finds a current one on your account automatically and says which it switched to.
- On the free tier, Groq limits requests per minute. RELAY waits and retries on its own, so a step may occasionally take longer.

### Option B — Local model with Ollama (free, offline, no key)

1. Install Ollama from **https://ollama.com/download** and open it once.
2. Double-click **`run_local.bat`** (Windows). The first run downloads `qwen2.5:7b` for the agents (about 4.7 GB) and `qwen2.5vl:7b` for photos (about 6 GB).

Needs about 16 GB of RAM. On smaller laptops, run these first:
```bat
set OLLAMA_MODEL=qwen2.5:3b
set OLLAMA_VISION_MODEL=qwen2.5vl:3b
run_local.bat
```

Local models on a laptop CPU are slower, from a few seconds to a minute per agent step.

### Option C — Google Gemini

```bat
set RELAY_PROVIDER=gemini
set GEMINI_API_KEY=your_gemini_key
python scripts\check_provider.py
run.bat
```
Get a key from Google AI Studio. Free-tier daily limits are low, so Groq is the better choice for a full demo.

> **Keep keys private.** Never commit an API key, paste it into a public place or show it on screen. If one is exposed, delete it in the provider's console and create a new one.

---

## Demo walkthrough

1. **Warden console** (`/admin`, `warden` / `1234`): click **Reset demo data**.
2. **Report** from a phone by scanning a QR on the home page, for example AC-304: *"The AC is making a loud noise and isn't cooling properly."*
3. **Watch the agent trace** live in the warden console: tool calls, the citation check, the plan, the resolution criteria and the policy decision.
4. **Approve** the repair. It's electrical and above ₹1,500, so the agents had to stop and ask.
5. **Technician** (`/tech`, `ravi` / `1111`): open the job, follow the procedure and submit readings and a photo.
   - Submit an **old or unrelated photo**: RELAY rejects it and asks for a new photo on the same job.
   - Submit a **valid photo**: the incident moves to the resident for confirmation.
6. **Resident** answers on their tracking page. "Yes" closes it as **Verified**; "No" reopens it as attempt 2, carrying forward what failed.
7. Optionally, the warden clicks **Ask technician for new evidence** if they don't trust what was submitted.

---

## How it works

```
Resident (QR) ─► Diagnosis agent ─► Citation check (code) ─► Planner agent
                 equipment, history,   every cited record       manual, stock,
                 manual, similar cases must exist               technicians, cost, draft
                                         │
                 Resolution criteria fixed by code before the repair
                                         ▼
                 Policy engine (code) ── approval needed? ──► Warden
                                         ▼
                 Work order created by code (no agent can do this)
                                         ▼
          Technician evidence: readings, part, checklist, notes, photo
                                         ▼
     Deterministic checks + photo checks + Verifier agent + Resident answer
                                         ▼
                        Evidence fusion (fixed rule order)
        ┌──────────────┬───────────────────┬────────────────────┐
     VERIFIED    NEEDS MORE EVIDENCE   NOT VERIFIED /       No answer in window:
      close      ask for exactly       CONTRADICTION        VERIFIED, UNCONFIRMED
                 what's missing        reopen, new attempt
```

### The agent loop

All three agents share one loop:

- The system prompt defines a strict JSON protocol (**call a tool** or **give a final answer**), the agent's role and the tools it may use.
- The task arrives as JSON; tool results are fed back to the model.
- Every reply is validated against a schema. Invalid output is rejected and returned to the model with the error.
- Hard cap of **6 tool calls** per agent run. Hitting it hands the incident to the warden.
- On Groq, native tool calling is mapped onto the same protocol.

| Agent | Tools | Output |
|---|---|---|
| Diagnosis | `get_equipment`, `get_history`, `search_manual`, `get_similar_incidents` | Likely cause with cited manual sections and history |
| Planner | `get_manual_section`, `check_inventory`, `find_technician`, `estimate_cost`, `draft_work_order` | A repair plan (a draft only) |
| Verifier | `get_contract`, `get_evidence`, `get_check_results`, `get_resident_response`, `inspect_photo`, `get_history` | Findings, consistency and what evidence to ask for next |

### Who decides what

| Decision | Made by | Why |
|---|---|---|
| Likely cause | Diagnosis agent | Needs judgment over messy text and history |
| Citations are real | Code | The model never grades itself |
| Repair plan | Planner agent | Choosing among procedures, parts and people |
| Cost, hazard, stock, skills | Code, from the database | The model's numbers are not trusted |
| Approval | Policy engine + warden | The model never decides its own authority |
| Creating the work order | Code, after authorization | No agent has that tool |
| Pass/fail on readings | Code | Thresholds are not a judgment call |
| Hedged notes, conflicts, next evidence | Verifier agent | What rules can't do |
| Final outcome | Fixed fusion rules | Easy to read and defend |

### Evidence fusion (in order)

1. Required evidence missing → **NEEDS MORE EVIDENCE**
2. Any measured check fails → **NOT VERIFIED** (reopen)
3. The photo can't be trusted → **NEEDS MORE EVIDENCE**: a new photo on the same job, unless the resident has already said it's not fixed
4. Verifier finds the evidence inconsistent → **CONTRADICTION** (reopen)
5. Resident says it's not fixed → **CONTRADICTION** (reopen)
6. All pass, consistent, resident confirms → **VERIFIED**
7. All pass, no answer within the window → **VERIFIED, UNCONFIRMED** (a late "still broken" reopens it)

### Photo checks

| Check | Needs a model? | Catches |
|---|---|---|
| Perceptual hash (dHash) against every photo ever submitted | No | Reused photos, or the resident's "before" photo sent as proof |
| EXIF capture time vs. work-order time | No | Old gallery photos taken before the job |
| Blank or tiny image | No | Lens-cap shots and accidental blanks |
| Vision model | Yes (Groq, Gemini or Ollama) | People, documents, wrong equipment or unrelated scenes |

The photo checks are deterministic, so a model can't wave a bad photo through. A photo can block a closure but never prove one on its own. A rejected photo can't be resubmitted.

---

## Safety and responsible design

- **No agent can create or approve a work order.** The planner can only draft one.
- **Citation checking:** a diagnosis citing records that don't exist is downgraded and forces human approval.
- **Policy engine:** hazardous, expensive, out-of-stock or repeat jobs always need the warden.
- **Criteria fixed before the repair:** built from the resident's symptoms by code, so a model can't quietly drop a check.
- **No single party closes a ticket:** readings, the verifier and the resident must agree.
- **Bounded retries:** after 3 failed attempts, a human takes over.
- **Fails safe:** if the model is down or misbehaves, the incident goes to the warden with the reason, never a guess.
- **Restart-safe:** work interrupted by a server restart resumes automatically.
- **Full audit trace:** every tool call, check, decision and state change is stored, streamed live and replayable per incident.
- **Honest labelling:** the console always shows which model is running, including the offline demo agent.

---

## Tech stack

| Layer | Technology |
|---|---|
| Backend | Python, FastAPI, Uvicorn, SQLite (WAL) |
| Live updates | Server-Sent Events |
| Frontend | HTML, CSS and JavaScript (mobile-first, no framework), self-hosted Archivo font |
| QR codes | `qrcode` |
| Image checks | Pillow (dHash, EXIF) |
| Agent models | Groq `openai/gpt-oss-120b` (demo) · Gemini · Ollama `qwen2.5:7b` · offline demo agent |
| Vision models | Groq Llama 4 Scout (demo) · Gemini · Ollama `qwen2.5vl:7b` |
| APIs | Groq Chat Completions (tool calling) · Gemini `generateContent` · Ollama `/api/chat` |
| Tests | pytest |

---

## Testing

```bash
python -m pytest
```

There are **78 automated tests** covering:

- the agent guarantees: loop caps, validation and tool allowlists
- citation checking and policy rules
- the full HTTP flows for resident, technician and warden
- reopen cycles
- reused, old, blank and unrelated photos
- warden evidence requests
- duplicate reports
- restart recovery
- local and remote model providers, against simulated servers

To check a live model end to end, run `python scripts/check_provider.py`.

---

## Project layout

```
relay/
  main.py            FastAPI app: API routes, live trace stream, pages
  config.py          all settings, read from environment variables
  db.py, seed.py     SQLite schema and simulated campus data
  network.py         works out the address phones use for QR codes
  agents/            agent loop (cap, validation, trace), prompts, the three agents
  llm/               model providers (Groq, Gemini, Ollama) and the offline demo agent
  core/              workflow, state machine, policy engine, citations, resolution
                     criteria, evidence fusion, photo checks, tools, audit trace
  data/contracts/    resolution-criteria templates (AC, ceiling fan)
  web/               resident, technician and warden screens; printable QR labels
scripts/check_provider.py   live model check
tests/                      automated test suite
run.bat / run.sh            start RELAY
run_local.bat               start RELAY with local Ollama models
allow_phones.bat            Windows firewall rule so phones can connect
```

---

## Configuration

All settings are environment variables; see `.env.example` for the full list.

| Variable | Default | Purpose |
|---|---|---|
| `RELAY_PROVIDER` | `mock` | `mock` (offline demo agent), `groq`, `gemini` or `ollama` |
| `GROQ_API_KEY` / `GROQ_MODEL` | — / auto | Groq key and model (demo used `openai/gpt-oss-120b`) |
| `GEMINI_API_KEY` / `GEMINI_MODEL` | — | Gemini key and model |
| `OLLAMA_MODEL` / `OLLAMA_VISION_MODEL` | `qwen2.5:7b` / `qwen2.5vl:7b` | Local models |
| `RELAY_VISION_PROVIDER` | `auto` | Which model checks photos (`auto` uses the available key) |
| `RELAY_MAX_AUTONOMOUS_COST` | `1500` | Jobs above this (₹) need approval |
| `RELAY_MAX_TOOL_ITERATIONS` | `6` | Tool-call cap per agent run |
| `RELAY_MAX_CYCLES` | `3` | Repair attempts before a supervisor takes over |
| `RELAY_RESIDENT_WINDOW` | `86400` | Seconds to wait for the resident (use `60` for a demo) |
| `RELAY_PUBLIC_URL` | — | Public address for QR codes when deployed |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Phone says "site can't be reached" | Use the phone address printed in the RELAY window (with `:8000`). If it opens on the laptop but not the phone, run `allow_phones.bat` as administrator. College Wi-Fi often blocks devices from reaching each other; use a phone hotspot instead. |
| "Can't reach the RELAY server" | The server window was closed or paused. On Windows, clicking inside it can freeze it; press Esc. |
| `check_provider` doesn't print a version line | You're running an old copy. Delete old folders and re-extract the latest zip. |
| Groq `HTTP 403 error code: 1010` | Old copy of RELAY; update to 1.8. |
| Groq `HTTP 401` | Invalid or deleted key; create a new one. |
| "Your evidence is being checked" for a while | The verifier agent is running on the live model; it can take up to a minute or two. The page updates by itself. |
| `'python' is not recognized` | Reinstall Python with **Add Python to PATH** ticked. |
| "Address already in use" | RELAY is already running; just open the page. |

---

## What's real and what's simulated

**Real:**
- the agent loop and tool calling with live models
- the citation checker, policy engine and state machine
- resolution criteria, deterministic checks, photo forensics and evidence fusion
- the reopen loop, approvals and role-based screens
- QR intake and the live audit trace

**Simulated for the prototype:**
- Equipment, manual sections, maintenance history, parts and technicians are seed data (`relay/seed.py`).
- Readings are typed in by the technician; there are no sensors.
- Sign-in is demo-grade (PINs).

**Path to production:**
- the institution's real asset register and stores data
- readings from connected meters
- WhatsApp intake
- single sign-on
- Postgres instead of SQLite

---

Font: Archivo, SIL Open Font License (`relay/web/static/fonts/OFL-LICENSE.txt`).
