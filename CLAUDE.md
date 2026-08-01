# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

Team **linkedin-larpers**, competing in the **UQ Tech for Change 2026** hackathon.
One day (8 hours) to design a solution, build an MVP, and pitch it (3–4 minutes).

**Theme: Disaster and Emergency Management** for **culturally and linguistically
diverse (CALD) and hard-to-reach communities** — people physically present in a
warning zone but effectively invisible to the warning system.

Target region: **the Philippines** (Eastern Visayas / Tacloban as the demo
geography — the Haiyan storm-surge terminology failure is the anchor evidence).
See [`docs/research/philippines.md`](docs/research/philippines.md).

Judging rubric (drives every decision):

| Criterion | Weight |
| --- | --- |
| Problem Definition (supported by evidence) | 20% |
| Strategy / Solution | 50% |
| What Does Success Look Like? | 10% |
| Delivery and Presentation | 20% |

70% is problem + solution, and problem marks are evidence-gated. Unsourced
claims cost marks. Every number needs a source (`docs/research/sources.md`).

## The product: PhilAlert

An iOS app, displayed as **PhilAIert** (capital I where the second l sits —
visually identical in sans-serif, embedding "AI" in the name). The app IS the
whole deliverable — **frontend and backend in one; there is no server, no
OpenAPI contract** (owner decision). All content ships in `FixtureStore` as
the stand-in for a human-verified template bank.

The four-step chain the brief demands — **receive → understand → believe →
act** — maps to features:

- *receive*: SMS deep link `handaph://a/{token}` (Universal Link `rdy.ph` in
  production) opens the exact alert an SMS summarised
- *understand*: 7 languages (incl. Waray), plain-language glossary, pictogram
  strips, text-to-speech, audio-first mode, AI Assistant (retrieval-grounded)
- *believe*: named barangay co-sign on alerts, verification-state chips on
  every translation, named sources on NGO map layers
- *act*: personalised risk banner + quantified index, in-app walking routes
  with ETA, demographic+scenario Plan page, "I'm Safe" family SMS,
  one-tap emergency numbers

## Repository layout

```
README.md               Brief + full app documentation + risk formulation
CLAUDE.md               This file
docs/app-icon.jpg       Logo (PH flag + pin/alert/bell) — also the app icon
docs/architecture.md    System architecture; §15 = risk quantification maths
docs/research/          Evidence base — read before proposing anything
Phillipines reports/    Team-supplied PDFs
ios/                    The app
  project.yml             XcodeGen definition (edit this, then `xcodegen generate`)
  HandaPH.xcodeproj       Generated, committed for teammate convenience
  Config/Secrets.xcconfig Committed defaults; real key in Secrets.local.xcconfig (git-ignored)
  HandaPH/                Sources: App/, Core/ (Models, Data, Risk, Assistant,
                          Localization, Speech, DesignSystem), Features/
                          (Alerts, Map, Glossary, Plan, Assistant, CheckIn, Settings)
  HandaPHUITests/         XCUITest smoke suite (keep green)
```

## Stack & key implementation facts

- **Swift 6 toolchain / SwiftUI, iOS 17+, zero external packages.** Swift 5
  language mode (strict concurrency deferred).
- **Maps:** Apple MapKit today; MapLibre + OSM offline tiles is the documented
  swap (`HazardMapView` is the seam). **OSM data IS live**: `OSMData.swift`
  bundles 32 Overpass-extracted POIs (ODbL, attributed on map + About).
- **AI Assistant:** Claude `claude-haiku-4-5` via the Messages API, grounded
  ONLY on injected verified glossary/alert content + a coarse on-device
  situation summary; forbidden from composing warnings. Offline/no-key path
  answers deterministically from the corpus. **No LLM ever writes a warning.**
- **Risk index:** `R = min(1, H·P·E·V)` — hazard intensity × proximity decay
  e^(−d/10 km) × geographic exposure (hazard-zone polygon; NOAH/DEM stand-in)
  × household vulnerability. Bands ≥0.75 danger / ≥0.35 warning. Full table:
  README + `docs/architecture.md` §15. Implemented in `RiskEngine`.
- **Localization:** `L10n` chrome strings + `LocalizedText` content values,
  each carrying a verification state rendered as a chip; chips open a
  "suggest better wording" sheet. English/Tagalog/Cebuano/Waray populated;
  Ilocano/Hiligaynon/Bikol fall back (visibly, never silently).
- **Onboarding:** language (with in-language greeting per option, big
  scroll-down arrow) → age band (60+ auto-enables larger text, read-aloud,
  slower voice), back button, fully in the chosen language.
- **Privacy:** household profile and location never leave the device; the
  assistant sends only coarse summary strings; deep-link receipts send an
  opaque token only.

## Working conventions

- **Owner (Imira) pushes to `main` after each feature batch** — commit on
  `imira`, merge to `main`, push both. This supersedes the earlier PR flow.
- **Keep the UI test suite green** (`xcodebuild test`, iPhone 16 Pro sim).
  Suite flakes after many consecutive runs = simulator fatigue; reboot the
  simulator before diagnosing the app.
- **Never commit secrets.** The Anthropic key lives in
  `ios/Config/Secrets.local.xcconfig` (git-ignored). The committed
  `Secrets.xcconfig` must keep an empty default.
- Evidence first; flag uncertainty inline; no AI slop — content is written by
  people, retrieved by machines.
- Design artifacts: Figma file "HandaPH — Map & Personalised Risk"
  (https://www.figma.com/design/ChaDRzvQJQiaNEC2qCKJCM) — palette, map spec,
  assistant spec.

## Build / demo commands

```sh
open ios/HandaPH.xcodeproj                    # build & run: ⌘R (Xcode 16+)
cd ios && xcodegen generate                   # after editing project.yml
xcrun simctl location booted set 11.2433,125.0039   # stand in Tacloban
xcrun simctl openurl booted "handaph://a/7Kq2"      # the SMS-link moment
# no Xcode selected? prefix commands with:
#   DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
```

Deep-link money shot: storm-surge alert `7Kq2` in Waray; `9Xw4` and `2Fb8`
are the other fixture tokens.

## Hard constraints from the brief (still binding)

- No AI slop; every number sourced; translations honestly labelled.
- Don't assume app installs — SMS carries the full message; the app is depth.
- Community must be named: Waray speakers / Eastern Visayas (Cebuano variant
  documented as the alternative).
- Offline behaviour defined for every feature (Odette: weeks without telecoms).
  Demo may run online, but never remove the offline paths.
- Psychological/social factors count: trust (co-sign), warning fatigue
  (relevance radius), meaning lost in translation (glossary, pictograms).
