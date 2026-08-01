# System architecture

Target: an **iOS application for iPhone**, backed by **SMS notifications that deep-link
into the app**, for culturally and linguistically diverse communities in the
**Philippines**.

This document is the architecture plan, not an implementation. It states what gets
built, in what language, on what framework, and why — and separates the **8-hour
demo build** from the **production design**, because the pitch has to describe the
second while showing the first.

Evidence for every constraint is in [`research/philippines.md`](research/philippines.md)
and [`research/sources.md`](research/sources.md).

---

## 1. Constraints that drive every decision

These are not preferences. Each one is a documented finding, and each one kills a
class of designs.

| # | Constraint | Evidence | What it rules out |
| --- | --- | --- | --- |
| **C1** | The last mile fails at **comprehension**, not delivery | Haiyan: warnings received, "storm surge" not understood, 6,300 dead | Anything whose value proposition is "we deliver alerts faster" |
| **C2** | **The network dies in the event** | Odette 2021: 135 municipalities lost telecoms, 227 lost power, 2–8 weeks to restore, longer in remote areas | Any feature that needs connectivity to be useful during response |
| **C3** | **Data is expensive and scarce** | Only ~18% of households have home internet; ~65% lack easy web access; mobile broadband costs 2.04% of monthly GNI vs the <2% affordability threshold; prepaid dominates | Heavy app payloads, video, chatty polling, cloud-round-trip UX |
| **C4** | **SMS is one-way and there is no feedback loop** | CFE-DM 2025: "SMS blast messages are likely to be more reliable and scalable although they only allow one-way communication. Gaps… and the feedback loop for communities to pass information back to decision-makers…" | Treating SMS as the whole system, or as a solved problem |
| **C5** | **Trust is the binding constraint** | 64% of Filipino internet users are concerned about real vs fake information online; documented disinformation-for-hire in the 2022 elections; WRP finds confidence in government varies regionally | Anonymous or unattributed alerts; anything that looks like a chain message |
| **C6** | **The trusted-messenger layer already exists and has no tooling** | Barangay/BDRRMC is statutory; LGUs warn via "SMS and social media, but also via emergency vehicles with megaphones or community or church bells" | Designing only for the end resident and ignoring the official who actually speaks to them |
| **C7** | **Machine translation is a credibility risk** | COVID-19 AU: fast, poor translations damaged trust. Brief says: no AI slop | Piping an LLM/MT API straight to a life-safety message |
| **C8** | **iPhone is ~12.66% of Philippine handsets** (Android ~87%) | CFE-DM 2025 | An iOS-only system claiming universal reach — see §11 |
| **C9** | Warning fatigue is real and permanent | Six typhoons in 30 days (2024); peer-reviewed WEA opt-out research | Increasing message volume without increasing relevance |

**The architecture that falls out of this:** SMS is the *reach* layer and must carry
standalone value; the iOS app is the *depth* layer and must work fully offline; the
comprehension work happens **server-side, ahead of time, from verified content** — never
live-generated on the critical path.

---

## 2. System overview

```
┌──────────────── SOURCES (real, public) ────────────────┐
│ PAGASA (weather/TC/flood)   PHIVOLCS (quake/volcano)   │
│ TEWS (tsunami)              GeoRiskPH: HazardHunterPH, │
│ GDACS / USGS                GeoAnalyticsPH, FaultFinder│
└────────────────────────┬───────────────────────────────┘
                         │ poll / webhook / fixture
                ┌────────▼─────────┐
                │  INGEST SERVICE  │  normalise → CAP 1.2
                └────────┬─────────┘
                         │
                ┌────────▼─────────────────────────────────┐
                │           ALERT PIPELINE                 │
                │  1 normalise   (→ canonical Hazard event)│
                │  2 classify    (→ traffic-light + phase) │
                │  3 target      (→ affected geometries)   │
                │  4 compose     (→ template, not free text)│
                │  5 localise    (→ 5 languages, verified) │
                │  6 render      (→ SMS / push / app / TTS)│
                └────┬──────────────────────┬──────────────┘
                     │                      │
          ┌──────────▼────────┐   ┌─────────▼──────────┐
          │  SMS GATEWAY      │   │  MOBILE API        │
          │  160-char, emoji, │   │  REST + JSON       │
          │  traffic-light,   │   │  ETag / delta sync │
          │  short link       │   └─────────┬──────────┘
          └──────────┬────────┘             │
                     │  Universal Link      │
                     └──────────┬───────────┘
                          ┌─────▼──────────────────────┐
                          │   iOS APP (SwiftUI)        │
                          │   offline-first local DB   │
                          │   MapLibre + OSM (PMTiles) │
                          │   on-device glossary + TTS │
                          └─────┬──────────────────────┘
                                │ upstream reports (when signal returns)
                                └──────────► FEEDBACK API ──► barangay console
```

Three planes, deliberately separated:

1. **Reach plane (SMS)** — works on every handset, including feature phones, and on
   whatever sliver of network survives. Must be *complete on its own*.
2. **Depth plane (iOS app)** — map, plan, glossary, protocols. Must work with the
   radio off.
3. **Return plane (feedback)** — receipt, comprehension, resident reports. Closes C4.

---

## 3. Languages and frameworks — the summary

| Layer | Language | Framework / library | Why |
| --- | --- | --- | --- |
| **iOS app** | **Swift 6** | **SwiftUI** | Native, fastest path to an accessible UI; Dynamic Type, VoiceOver and localisation are first-class rather than bolted on |
| Maps | Swift | **MapLibre Native (iOS)** + **OpenStreetMap** data | Open source per the brief; unlike MapKit it supports **offline vector tiles**, which C2 makes mandatory |
| Offline tiles | — | **PMTiles** / MBTiles, built with **Tippecanoe** | Single-file tile archive for one municipality, shipped in-bundle or downloaded once on Wi-Fi |
| Location | Swift | **Core Location** | 1 km radius view; significant-location-change mode to protect battery |
| Local storage | Swift | **SwiftData** (or **GRDB.swift** if we need raw SQL/FTS) | Offline-first cache of alerts, plans, glossary, protocols |
| Speech | Swift | **AVSpeechSynthesizer** | On-device TTS; has Filipino (`fil-PH`) — regional-language coverage must be tested, see §7.4 |
| Deep links | Swift | **Universal Links** + `apple-app-site-association` | SMS link opens the exact alert in-app; falls back to web if not installed |
| Push | Swift | **APNs** via `UserNotifications` | Secondary channel when data exists; never the only one |
| **Backend API** | **Python 3.12** | **FastAPI** + **Uvicorn** + **Pydantic v2** | Best fit for geospatial + data work, and the team's maths/engineering strength; Pydantic gives typed schemas the iOS side can be generated against |
| Database | SQL | **PostgreSQL 16 + PostGIS** | `ST_Intersects` on alert polygons vs user points is the core targeting query; PostGIS is not optional for this |
| Migrations / ORM | Python | **SQLAlchemy 2.0** + **Alembic** | Standard, unremarkable, works |
| Geospatial | Python | **Shapely**, **GeoPandas**, **pyproj** | Polygon ops, elevation/aspect joins, buffer generation |
| Background work | Python | **APScheduler** (demo) → **Celery + Redis** (production) | Alert polling and dispatch fan-out |
| Alert format | — | **CAP 1.2** (OASIS Common Alerting Protocol) | The international standard PAGASA/NDRRMC-class systems speak. Using it is the difference between a toy and something that could actually integrate |
| SMS | Python | **Twilio** SDK (demo) / **Semaphore** or **Movider** (PH-local) | Twilio for a reliable demo; PH-local providers for real PH sender IDs. Production reality in §10 |
| Hosting | — | **Railway** / **Fly.io** / **Render** + **Neon** or **Supabase** Postgres | One-command deploy, free tier, PostGIS available |
| Contract | — | **OpenAPI 3.1** (auto-generated by FastAPI) | The merge risk is the API. Generated spec + mock server means frontend never waits on backend |
| Barangay console | TypeScript | **Next.js** (only if time allows) | Deliberately last — see §9 cut list |

**Alternative considered and rejected:** a TypeScript/Node backend (Fastify + Prisma +
PostGIS). Perfectly viable and arguably easier to share types with a web frontend. Chosen
against because the hazard/geo/elevation work is materially easier in Python, and because
the iOS client does not share types with the backend anyway.

---

## 4. The alert pipeline in detail

This is the product. Everything else is plumbing.

### Stage 1 — Normalise
Ingest heterogeneous sources into one canonical `HazardEvent`. Output conforms to
**CAP 1.2**: `identifier`, `sender`, `sent`, `status`, `msgType`, `scope`, plus per-`info`
blocks with `category`, `event`, `urgency`, `certainty`, `severity`, `area` (polygon or
geocode), and — critically — `language`. CAP is *designed* for multilingual alerting: one
alert, multiple `<info>` blocks, one per language. We are not inventing a format.

### Stage 2 — Classify
Map CAP `urgency` × `severity` × `certainty` onto a **three-tier traffic light**, and
onto an explicit **phase**:

| Tier | Colour | Phase language (English) | Meaning |
| --- | --- | --- | --- |
| 1 | 🟢 Green | "This may happen" | Advisory — be aware |
| 2 | 🟡 Yellow | "This is coming" | Prepare and be ready to move |
| 3 | 🔴 Red | "This is happening NOW" | Act immediately |

The brief demands the phase be unmistakable. Haiyan is why: people knew a typhoon was
coming and misjudged *what it would do to them*. Tier and phase are **separate fields**,
never collapsed into prose.

### Stage 3 — Target
PostGIS query: which registered users' locations fall inside the alert geometry, buffered
by hazard type. Elevation joins here too — for storm surge and tsunami, a user below a
threshold elevation inside the polygon gets a different, stronger message than one above
it. **Precision is a safety feature (C9):** every over-broad alert damages the next one.

### Stage 4 — Compose (templates, never free generation)
Message text comes from a **versioned template bank**, keyed by
`(hazard_type, tier, phase, audience)`. Templates contain slots (`{barangay}`,
`{time}`, `{elevation_note}`) — nothing else. **No LLM writes a warning.** This is the
direct answer to C7 and to the brief's "no AI slop", and it is the thing to say out loud
in the pitch.

### Stage 5 — Localise
Five languages per the brief: **Tagalog, Cebuano (Bisaya), Ilocano, Hiligaynon (Ilonggo),
Bikol** — plus English. Every template is translated **once, ahead of time, by a human**,
and stored with a `verification_state`:

- `human_verified` — a speaker approved it. **Only these ship in Tier 3 messages.**
- `machine_assisted` — MT draft, pending review. Usable for low-tier informational content, always labelled.
- `untranslated` — falls back to English + pictogram + map.

The **hazard glossary** is separate and is the Haiyan fix: for each technical term
("storm surge", "lahar", "aftershock", "evacuation centre"), a short **explanation by
analogy**, per language, checked by speakers — not a dictionary gloss. This is what the
chatbot serves.

### Stage 6 — Render per channel
One event, several renderings:

- **SMS** — ≤160 GSM-7 characters where possible; emoji forces UCS-2 (70 chars), so the
  emoji budget is tiny and deliberate. Structure: `[emoji hazard][colour word] · what ·
  where · when · ONE action · short link`.
- **Push** — same content, richer.
- **App detail** — full protocol, map, glossary links, TTS.
- **TTS text** — a spoken variant with punctuation for prosody and no URLs.
- **Pictogram set** — hazard icon + action icon, language-independent (C1).

**Worked SMS example** (illustrative, needs native-speaker review before any use):

```
🌊🔴 DELIKADO NGAYON
Tubig-baha sa Brgy San Jose.
Umakyat sa mataas NGAYON.
Detalye: rdy.ph/a/7Kq2
```

---

## 5. The SMS → app deep link

The mechanism the brief asks for, end to end:

1. Pipeline dispatches SMS containing a short URL: `https://rdy.ph/a/{token}`.
2. `token` is a short, opaque, single-alert reference — **not** a user ID, and it carries
   no PII (C5, §8).
3. Domain serves `/.well-known/apple-app-site-association`, so iOS treats it as a
   **Universal Link**.
4. **App installed** → opens directly on that alert's detail screen, in the user's
   language, with the map already centred. No login, no search, no navigation.
5. **App not installed** → the same URL serves a **lightweight mobile web page** with the
   same content. This matters enormously: it means the SMS works for the ~87% of handsets
   that are Android and for anyone who never installs anything (C8, and the brief's own
   "don't assume people download apps").
6. Opening the link fires a **receipt event** — the first half of the feedback loop (C4).

**Design rule:** the SMS must be *sufficient on its own*. The link adds depth; it is never
required to understand what to do. If someone reads only the SMS, they have the hazard,
the location, the urgency, and one action.

---

## 6. Data model (core entities)

```
HazardEvent      id, source, external_id, hazard_type, cap_xml, onset, expires,
                 geometry (PostGIS), severity, certainty, urgency, status
Alert            id, hazard_event_id, tier, phase, template_key, issued_at,
                 supersedes_id, revoked_at            ← revocation is mandatory (Grenfell)
AlertRendering   id, alert_id, language, channel, body, verification_state, tts_text
Template         key, hazard_type, tier, phase, audience, slots[], version
Translation      template_key, language, body, verification_state, verified_by, verified_at
GlossaryTerm     term, hazard_type, language, plain_explanation, analogy,
                 pictogram_id, verification_state
Protocol         hazard_type, phase, language, steps[] (ordered, imperative, pictogrammed)
UserProfile      id, phone_hash, language, barangay_code, home_point, elevation_m,
                 accessibility_prefs, consent_flags
Delivery         id, alert_id, user_id, channel, sent_at, opened_at, acknowledged_at
CommunityReport  id, user_id?, barangay_code, point, hazard_type, note, photo_ref,
                 created_at, verification_state       ← the return path (C4)
```

Two schema decisions worth defending in the pitch:

- **`supersedes_id` / `revoked_at`.** Grenfell's "stay put" could not be withdrawn.
  Every alert here can be superseded or revoked, and the app must visibly show when
  earlier advice no longer applies.
- **`verification_state` is on the rendering, not the alert.** The same alert can be
  human-verified in Cebuano and machine-assisted in Ilocano, and the user is told which.

---

## 7. The iOS application

### 7.1 Structure
Swift 6, SwiftUI, MVVM. Minimum deployment target chosen for **reach, not novelty** —
older iPhones are exactly what the target community owns, so target **iOS 17+** and treat
anything newer as progressive enhancement.

```
App/
  Features/
    Alerts/        list, detail (Universal Link entry point), history
    Map/           MapLibre, 1 km radius, landmarks, hazard overlays
    Plan/          personalised prevention/preparedness plan
    Protocols/     per-hazard emergency protocol (the 10 hazard types)
    Glossary/      searchable plain-language hazard terms + TTS
    Assistant/     Q&A over glossary/protocols (see 7.5)
    Report/        upstream community report (queued when offline)
    Settings/      language, text size, accessibility, consent
  Core/
    Persistence/   SwiftData stack, offline queue
    Sync/          delta sync, ETag, exponential backoff
    Location/      Core Location wrapper
    Speech/        AVSpeechSynthesizer wrapper
    DesignSystem/  colour tiers, pictograms, typography
```

### 7.2 Offline-first (C2, C3)
Non-negotiable. Ship in-bundle or fetch once on Wi-Fi, then never require the network:

- **Map tiles** — PMTiles for the target municipality, ~10–40 MB. Generated offline with
  Tippecanoe from an OSM extract (Geofabrik).
- **Landmarks** — hospitals, evacuation centres, barangay halls, high ground, extracted
  from OSM `amenity=hospital`, `emergency=*`, and local LGU lists.
- **Elevation** — coarse raster or per-barangay lookup, precomputed server-side and cached.
- **Glossary, protocols, templates** — all languages, versioned, delta-synced.
- **Last known alerts** — always readable, with a visible "last updated" timestamp.

Sync is **delta + ETag** over one endpoint, so a brief 2G window is enough to catch up.
Every screen must render with the radio off. This is the single most important
engineering property of the system and it should be demonstrated live.

### 7.3 Map
MapLibre Native, OSM raster/vector tiles, per the brief's OpenStreetMap requirement.
1 km radius default with zoom. Layers: user location, hazard polygon, evacuation centres,
hospitals, high ground, reported incidents. All symbology **pictogram-first**, with the
label as reinforcement rather than the carrier of meaning.

### 7.4 Accessibility
Not a feature — a scoring criterion and a moral requirement given the elderly are
over-represented in typhoon deaths.

- **Dynamic Type** throughout, tested at the largest accessibility sizes. No fixed frames.
- **VoiceOver** labels on every pictogram; the pictogram must have a text equivalent.
- **Contrast** ≥ 4.5:1; the traffic light must never be the *only* signal — colour is
  paired with an icon and a word, for colour-blind users.
- **TTS** via `AVSpeechSynthesizer`. `fil-PH` exists; **regional-language voice coverage
  for Cebuano/Ilocano/Hiligaynon/Bikol must be tested early** — if a voice is missing, the
  honest fallback is recorded audio for the fixed protocol steps, which is also more
  trustworthy. Do not claim coverage we have not verified.
- **Reduce Motion**, large tap targets (≥44 pt), one-handed reachability.

### 7.5 The assistant — deliberately not a chatbot
The brief asks for a chatbot for unfamiliar terms. The Haiyan evidence says this is the
highest-value feature in the product. It is also where a team can lose the room by
shipping AI slop.

**Design: retrieval over a verified corpus, not generation.**

- Query matches against the **glossary and protocol corpus** on-device (SwiftData +
  full-text search, or GRDB FTS5).
- Returns a **human-verified explanation**, with its pictogram and TTS.
- Works **fully offline** — which a cloud LLM cannot (C2).
- If there is no match, it says so and offers the nearest topics. It **does not
  improvise an answer about a life-safety question.**

Optional enhancement, only if signal exists and only for *navigational* questions
("where is the nearest evacuation centre?"), never hazard advice: an LLM call with
strict grounding. Apple's on-device **Foundation Models framework** is attractive here but
requires very recent hardware — precisely what this community does not have — so it
cannot be the primary path.

Saying "our assistant cannot hallucinate, because it retrieves human-verified content
rather than generating it" is a strong, honest line in a pitch that has been told to
avoid AI slop.

---

## 8. Security, privacy, and trust

Trust is the product (C5), so this is not boilerplate.

- **Location stays on device** wherever possible. Send the **barangay code**, not raw
  coordinates, for targeting; send a point only when the user files a report and consents.
- **Phone numbers stored hashed** (salted). Never in logs, never in the deep-link token.
- **Deep-link tokens are opaque, single-alert, and expiring** — a forwarded link leaks
  nothing about the recipient.
- **Message provenance is visible.** Every alert shows its issuing authority (PAGASA,
  PHIVOLCS, the LGU) and its verification state. An unattributed alert is
  indistinguishable from a chain message, and 64% of Filipino internet users are already
  worried about fake information.
- **Transport**: TLS 1.3, certificate pinning on the alert endpoint.
- **Consent** is explicit and granular for location, SMS, and analytics.
- **No advertising, no third-party trackers, no data resale.** Say this on a slide.

---

## 9. What actually gets built in 8 hours

The pitch describes the production design; the demo shows a vertical slice. Be explicit
about which is which — judges reward honesty and punish overclaiming.

**Must have (the demo spine)**
1. FastAPI service with 5–6 endpoints and a seeded Postgres/PostGIS database.
2. **Real archived alert as a fixture** — a genuine PAGASA/PHIVOLCS bulletin for the
   target municipality. Fixtures over live integration: identical on stage, no
   third-party outage risk, no venue-wifi dependency.
3. Template bank + glossary for **two languages** (English + Cebuano *or* Waray),
   human-checked. Two done properly beats five done by machine.
4. Real SMS send to a real handset on stage, with the traffic light, emoji and short link.
5. SwiftUI app: alert detail via Universal Link, offline map with a hazard polygon, one
   protocol, glossary lookup with TTS.
6. **Airplane-mode demo** — the highest-impact 15 seconds available to us.

**Nice to have**
7. Community report → barangay console.
8. Delivery/receipt telemetry dashboard.
9. Third and fourth languages.

**Cut first, without discussion**
10. Auth and user accounts (hardcode the demo user).
11. The Next.js barangay console (a static screenshot in the deck is worth the same marks
    for a fraction of the time).
12. Live API integrations.
13. Push notifications (SMS is the story; APNs adds provisioning pain for no narrative gain).

**Critical path:** the **OpenAPI contract** must be agreed and mock-served in **hour 1**.
Backend and frontend then build in parallel against the mock. Everything else can slip;
this cannot, and it is the single largest risk to a 6-hour merge.

---

## 10. Production reality (say this in the pitch — it shows we understand the domain)

Under **RA 10639 (Free Mobile Disaster Alerts Act)**, disaster alerting in the Philippines
runs through mandated telco channels at the direction of NDRRMC / PAGASA / PHIVOLCS.
A real deployment is therefore **not** a startup blasting Twilio messages. It is:

- an **LGU/barangay-operated tool** under the existing BDRRMC structure (C6), and
- an integration with **GeoRiskPH / PhilAWARE / PAGASA feeds** on the ingest side, and
- a **content layer** — the verified template bank, glossary and pictogram set — which is
  the actual intellectual contribution and the thing that is missing today.

Two facts to deploy in the pitch:
- **In 2019 only 1,368 LGUs had operating early warning systems, out of a potential
  ~43,000** regional/provincial/city/municipal/barangay units. The gap is not awareness.
- PAGASA's **impact-based forecasting project (IBFPh)** explicitly aims to communicate
  "what the weather **will do** rather than what the weather **will be**", with target
  areas including **Leyte**. Our design is aligned with the direction the national system
  is already moving — we are not proposing something they would reject.

**Prior art to acknowledge, not pretend away:** `MapaKalamidad.ph` already does
crowd-sourced live disaster mapping with a chatbot. Our differentiation is the
**verified multilingual comprehension layer and the barangay-official tooling** — not the
map. A judge who knows the space will respect the distinction and punish its absence.

---

## 11. The iOS-only question — answer it before you're asked

**Apple devices are ~12.66% of Philippine handsets; Android is ~87%.** A judge may well
raise this, and it is a fair challenge to a solution aimed at underserved communities.

The honest, strong answer:

> The **SMS layer reaches every handset**, including feature phones, and it carries the
> complete safety message on its own. The link falls back to a lightweight web page, so
> the depth layer is available on Android today without an Android build. The iOS app is
> the **reference implementation** of the depth layer — it is what we could build to a
> high standard in the time available, and it proves the architecture. Android is a
> port of the client, not a redesign of the system: the pipeline, the verified content
> and the SMS layer are all platform-independent.

That is a genuinely defensible position **because the architecture puts the value in the
content layer and the SMS plane, not in the app**. If the pitch instead implies the iPhone
app is the product, the 12.66% figure is fatal. Frame it correctly and it becomes a
strength: we designed for the phone people actually have, and built depth for one platform.

---

## 12. Demo script for a 3–4 minute pitch

Timings are deliberate; the demo is the middle, not the whole.

| Time | Beat | Content |
| --- | --- | --- |
| 0:00–0:40 | **The problem, with a body count** | 2013, Tacloban. PAGASA forecast Haiyan correctly. The warning went out. People received it. Over 6,000 died — because it said **"storm surge"**, a term Waray speakers had never heard, while officials translated English technical text on the fly. Survivors call it a tsunami: a word they already had, and would have run from. |
| 0:40–1:00 | **Why it persists** | Philippines: most at-risk country **21 years running**. 175 languages. Eastern Visayas has the **lowest resilience score in the country and it fell further between 2021 and 2023**. Odette knocked out telecoms in 135 municipalities for weeks. |
| 1:00–1:20 | **The insight** | Delivery is not the gap. Every barangay already has a trusted leader and a legal alerting mandate. What's missing is the layer between the forecast and the fisherman. |
| 1:20–2:40 | **DEMO** | (a) Trigger a real archived PAGASA bulletin. (b) **A phone on the podium buzzes** — traffic-light SMS, hazard emoji, one action, short link. (c) Tap → app opens on that alert, in Cebuano. (d) Tap the unfamiliar term → plain-language explanation + **TTS speaks it aloud**. (e) **Put the phone in airplane mode. Everything still works** — map, protocol, glossary. |
| 2:40–3:10 | **Why it's not AI slop** | Every message comes from a **human-verified template bank**, not a language model. The app shows verification state. The assistant *retrieves*; it cannot hallucinate. |
| 3:10–3:40 | **Success metrics** | Time-to-comprehension; % alerts delivered human-verified in the user's language; open-rate via deep link (the feedback loop that does not exist today); community reports returned upstream. |
| 3:40–4:00 | **Close** | The system that failed in 2013 wasn't the forecast. It was the sentence. We built the sentence. |

**The moment that wins it is airplane mode.** Rehearse it until it cannot fail, and have
a screen recording as a fallback.

---

## 13. Risks

| Risk | Likelihood | Mitigation |
| --- | --- | --- |
| API contract drift between backend and iOS | **High** | OpenAPI + mock server agreed hour 1. Non-negotiable. |
| Xcode/simulator/provisioning burns hours | High | Simulator only; no physical-device deployment for the app. Real SMS goes to a real phone — that part is easy. |
| Venue wifi fails mid-demo | Medium | Everything fixture-backed and local; airplane mode is *already* the demo. Screen recording as backup. |
| MapLibre offline tiles fight back | Medium | Generate PMTiles in hour 1, before anything depends on them. Static map image as fallback. |
| No native speaker to verify translations | **High** | Ship **two** languages verified rather than five unverified, and say so on stage. This is a strength, not an apology. |
| TTS voice missing for a regional language | Medium | Test in hour 1. Fall back to `fil-PH` or recorded audio; disclose honestly. |
| Overclaiming in the pitch | Medium | §10 and §11 exist precisely to pre-empt the two hardest questions. |

---

## 14. Open decisions

1. **Target community and language pair** — Waray / Eastern Visayas (strongest evidence
   link to Haiyan, lowest resilience score in the country) versus Cebuano / northern Cebu
   (most recent compound disaster, and Cebuano is on the brief's dialect list; **Waray is
   not**). This choice cascades into tiles, glossary and templates, so **decide first**.
2. **Primary phase** — the brief wants one stated. Preparedness + Response is the
   defensible pair; Recovery is the most under-served but the hardest to demo.
3. **Whether to build the barangay console** — highest differentiation per §10, highest
   time cost. Recommend: design it, screenshot it, don't build it.
4. **SMS provider** — Twilio (reliable, instant) versus a PH-local provider (authentic
   sender ID, slower to set up). Recommend Twilio for the demo, and say why in one line.

## 15. Personal risk quantification

The banner's number is not a vibe — it is `R = min(1, H · P · E · V)`,
taken as the maximum over all currently relevant alerts, displayed ×100.

| Term | Meaning | Values | Data source |
| --- | --- | --- | --- |
| **H** | Hazard intensity | danger 1.0 · warning 0.6 · advisory 0.3 | Official alert classification (PAGASA/PHIVOLCS via CAP) |
| **P** | Proximity decay | e^(−d / 10 km); region-wide alerts 0.5 | Alert centroid vs user location (on device) |
| **E** | Exposure | inside mapped hazard zone ×1.5 · self-reported near-coast ×1.25 · else ×1.0 | Hazard polygons — demo geometry standing in for Project NOAH inundation / DEM elevation layers over OSM base data |
| **V** | Household vulnerability | 1 + 0.15·elderly + 0.15·limited-mobility + 0.10·children<5 + 0.10·single-storey, capped 1.5 | Self-reported household profile, stored on device only |

Bands: **R ≥ 0.75 → danger**, **R ≥ 0.35 → warning**, else advisory.
Worked example (demo fixture): storm-surge *danger* alert 2.3 km away,
elderly household member → R = 1.0 × e^(−0.23) × 1.0 × 1.15 = **0.91 →
danger, index 91**. Same alert, same distance, no vulnerability factors →
0.79. Standing inside the surge polygon forces E = 1.5 → clamps to 1.0.

Why this shape: H and P are the *general* reasoning any warning system
has; E and V are the *specific* data only this app holds — measured
geography and volunteered demographics. The multiplication is the point:
the same official alert lands differently on different households, and
the formula makes that difference explicit, explainable, and computable
offline in microseconds. E's zone test is ray-cast point-in-polygon; in
production the polygons come from Project NOAH / LiDAR DEM (elevation),
so "your house is 2 m above sea level" enters through E without the user
reporting anything.

Open data in the chain today: OSM POIs (Overpass extract, ODbL) drive
evacuation-centre proximity in advice and the assistant's "where do I go";
the surge polygon is the placeholder for NOAH/DEM layers. Response-phase
credibility comes from *named* partner layers — Red Cross/DSWD/Caritas
feeding sites and LGU-configured emergency numbers — each rendered with
its source attached, because provenance is what makes an open map
believable to a community that has been burned by rumours before.
