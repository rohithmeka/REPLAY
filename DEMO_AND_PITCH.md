# RELAY: demo video script and pitch notes

## Before recording

1. Start with a live model if you can (`RELAY_PROVIDER=gemini`, run `python scripts/check_provider.py` first). Otherwise the mock works and is labelled honestly.
2. Set `RELAY_RESIDENT_WINDOW=60` so you can show the unconfirmed-close path if you want.
3. In the warden console, click **Reset demo data**.
4. If you'll scan with a real phone, read the phone address from the RELAY window and check the phone opens it. Print `/labels` if you want stickers on camera.
5. Open three windows side by side: warden console (laptop width), resident page and technician page (phone width, or browser dev tools in phone mode).

## Video, about 3 minutes

| Time | Show | Say |
|---|---|---|
| 0:00 | Home page, the repair tag | "In our hostel, a repair is closed when the technician says it's fixed. Residents told us that's often not true. RELAY only closes a repair when the evidence agrees." |
| 0:15 | Phone: open AC-304's QR page, tap "Loud noise" and "Not cooling", send | "A resident scans the QR on the AC. No app, no login." |
| 0:30 | Warden console: incident appears, live trace streams | "Three agents start working. Every step is a real tool call: equipment record, four past incidents, the service manual, similar faults on other units." |
| 0:50 | Diagnosis card: green citation chips | "Every claim cites a record. Code checks each citation exists. The model doesn't grade its own confidence." |
| 1:00 | Decision card | "The policy engine is plain code. Electrical work and a ₹2,210 cost exceed what the agent may do alone, so it stops and asks. The agent can draft a work order; it can't create one." Click **Approve repair**. |
| 1:15 | Technician phone: job card, hazard band, procedure, proof-of-fix form | "The proof of fix was set before the repair, from the resident's symptoms." Fill: 27.8 → 20.9, noise none, FAN-2207, all steps, note "Noise resolved". Submit. |
| 1:40 | Resident phone: "Is the problem fixed?" Tap **No**, type "Still rattling at night" | "Every measured check passed. But the resident says no." |
| 1:55 | Console: **CONTRADICTION** stamp, verifier findings, yellow evidence request | "RELAY doesn't close it. The verifier names the conflict and decides what evidence would settle it: a vibration check and a 30-minute run. It reopens and investigates again, excluding the fix that failed. New diagnosis: worn mounting dampers." |
| 2:25 | Approve attempt 2. Technician submits without the extra observations | "The technician skips the new checks. RELAY asks for exactly what's missing, and keeps everything else." Fill them in. |
| 2:40 | Resident taps **Yes**. Console: **VERIFIED** stamp, history updated | "Now readings, notes and the resident agree. Verified, and written back into the unit's history." |
| 2:50 | Repeat failures tab, then Replay | "Units failing three times in 60 days are flagged for preventive inspection. And every run can be replayed from the audit trace." |

**Photo scene (30 seconds, strong with a Gemini key):** report FAN-212 "wobbling at full speed". It goes straight to the technician (cheap and safe, so no approval). As the technician, attach any random photo from your gallery (a selfie, a screenshot) and submit. The warden console shows **MORE EVIDENCE**: the photo was taken before the job and, with vision on, "shows a person, not a ceiling fan". The technician's screen says the photo wasn't accepted and requires a new one. Take a real photo of a fan and it goes through. Say: "A photo can't prove a repair, but a fake one can't close a ticket either."

Optional extra (shows a different path): report FAN-212 "wobbling at full speed". It's cheap and safe, so the policy engine sends it straight to the technician with no approval.

## Pitch lines

- One line: **"Existing tools check that evidence was submitted. RELAY checks whether the evidence agrees, and when it doesn't, it works out what's missing and reopens the investigation."**
- Thesis: "RELAY doesn't ask whether the task was performed. It asks whether the problem was solved."

## Competitors (name them yourself)

- CMMS tools such as OxMaint and Xenia already require a closing photo, reading or sign-off before a work order closes, and some use AI to check photos.
- Property-management agents (Lette, FacilityBot) handle intake, routing and tenant confirmation.
- RepairProof (a lablab.ai hackathon project, August 2026) audits whether evidence supports a repair *before* approval.

**What RELAY adds:** after the repair, it treats disagreement between the technician, the measurements and the resident as its own outcome; the agent generates a specific request for the evidence that would resolve it; and that request becomes required on the next attempt and feeds a new diagnosis. Authority stays in code, and every diagnosis citation is checked against the records.

Don't say "nobody verifies repairs". That's false and a judge may know it.

## Likely judge questions

**Where is the AI, if code makes the decisions?**
The agents investigate, choose hypotheses, plan, read free-text notes, spot hedges and conflicts, and decide what to ask for next. Code handles the parts that shouldn't be a judgment call: thresholds, money, safety and authority.

**How do you know the diagnosis isn't hallucinated?**
Every hypothesis must cite record IDs. Code checks each one. One invalid citation forces human approval; all invalid sends it to a human. It's tested.

**Can a technician upload any photo?**
No. Every photo is checked for reuse (perceptual hash), for a camera timestamp from before the job, for being blank, and, with a vision model, for what it actually shows. A suspicious photo blocks closure and the technician must take a new one.

**What if the technician lies about the readings?**
In this version readings are self-reported. That's why the resident is an independent signal and the notes are cross-checked. Next step: readings from connected meters.

**What if the model loops or breaks?**
Six tool calls maximum, schema validation on every call, and any failure hands the incident to the warden with the reason.

**What if the resident never answers?**
It closes as "verified, unconfirmed" after the window. A later "still broken" reopens it.

**What if two residents report the same AC?**
The second report joins the open incident, so there's no duplicate work. If someone reports it again after the repair, that counts as "not fixed" and reopens it.

**Is the demo scripted?**
Report a different fault on any unit. The agents query the database and the criteria change with the symptoms. You can also watch every tool call in the trace.

## User evidence (fill in with your real numbers only)

Run the short Google Form in your hostel groups and put the real counts here. For example:
"__ of __ residents report faults by WhatsApp or phone"; "__ of __ had a fault marked fixed when it wasn't"; one or two real quotes. Don't invent numbers.
