# What could have improved outcomes → design implications

Part 1 is retrospective and evidence-anchored: for each case, the specific intervention
that would plausibly have changed the outcome. Part 2 turns the recurring ones into
design constraints. Part 3 is scoped for an 8-hour build.

---

## Part 1 — Per-case counterfactuals

### Lismore 2022
- **A community-reporting channel feeding official warnings.** Residents could see the
  creeks rising while the gauges were broken or transmitting wrong data. A structured
  upstream path (even SMS-based) would have given the SES ground truth its own sensors
  had lost.
- **Delivery confirmation with escalation.** If the system had known the evacuation SMS
  was not landing, it could have escalated to another channel instead of assuming the
  town had been told.
- **Formal support for the informal rescue network.** 1,000+ people were rescued by
  neighbours with boats. Coordinating that layer — rather than treating it as
  freelancing — is the single largest realised capability in that event.

### Victorian floods 2022
- **Warnings in the languages of the local workforce**, pushed to workplaces as well as
  residents. Councils know which visa-holder cohorts work which farms; the language
  profile is not a mystery.
- **A worker-facing channel independent of the employer**, since employers were the
  ones instructing workers to ignore road closures.
- **State-wide consistency in language support**, rather than each municipality
  improvising.

### Black Summer 2019–20
- **Chronic-hazard messaging (smoke) treated as a first-class warning stream**, in
  language, targeted at caregivers of young children.

### Cyclone Alfred 2025
- **Explainer-first messaging for a hazard with no community memory**: not just "Category
  2 expected", but what a cyclone does to a Brisbane street, for a population that has
  never seen one.
- **Managing multi-day uncertainty explicitly** — telling people *why* the track keeps
  changing, to spend credibility deliberately rather than lose it to fatigue.

### Lahaina 2023
- **Distinguishable per-hazard signals.** The sirens went unused because one tone could
  not distinguish "go inland" from "do not go inland". Distinct patterns per hazard
  would have made the network usable.
- **A channel that survives power and cell loss** — the plan had none.
- **Pre-translated evacuation messaging for a known-multilingual population.** The
  after-action report names this; Lahaina's language mix was not a surprise.
- **Live route validity in the message.** The Bypass closed at 3:20 pm; people were
  still being directed toward it.

### Valencia 2024
- **Pre-authorised automatic triggers.** If a defined gauge threshold auto-issues the
  alert, the 3-hour human decision gap does not exist. The Japanese embassy warned its
  nationals a day earlier off the same public data — the information was sufficient;
  the authority to act on it was the bottleneck.
- **Clear escalation when the responsible body does not act.**

### Türkiye–Syria 2023
- **Service-access information as a distinct product** — where is water, medical care,
  shelter, registration; in Arabic as well as Turkish; reachable without documentation.
- **Pre-registered, pre-coordinated international SAR** to compress the first 72 hours.

### Tōhoku 2011
- **Directive-register warnings** ("evacuate now", not "3 m wave expected") — which
  Japan implemented afterwards.
- **Multilingual and Easy-Japanese warnings from the start.** The gap had been
  identified in 1995 and a hotline built; it was not institutionalised.

### Grenfell 2017
- **A revocation mechanism for standing advice.** "Stay put" needed a designed,
  rehearsed path for being withdrawn the moment compartmentation failed — and a way to
  push that reversal to every flat.

---

## Part 2 — Design constraints (recurring across cases)

**C1. Fix the source message before translating it.**
Co-TEM's central finding: official messages are jargon-laden and ambiguous, which
defeats translation downstream. Plain-English simplification is a prerequisite, and it
independently helps low-literacy and high-stress readers.

**C2. Every message must carry an action, not just a condition.**
Tōhoku's post-2011 shift. "What do I do, right now, from where I am."

**C3. Never let raw machine translation reach the public unverified.**
COVID-19 in Australia showed fast-wrong translation damages trust durably. Community
verification, pre-approved templates, or human review must sit in the loop. This is also
the honest answer to the brief's "no AI slop".

**C4. Route through trusted messengers.**
The most evidence-backed intervention available. A message from a known community leader
is believed; the same message from an unfamiliar institution may not be.

**C5. Assume no app, no smartphone, no data.**
The brief says so explicitly, and Lahaina proved the infrastructure case. Design the
degraded path first — SMS, cell broadcast, voice, radio, printed, word-of-mouth.

**C6. Relevance is a safety feature.**
Over-alerting causes opt-out, and opt-out is permanent. A geographically or
demographically over-broad alert damages the next alert. Precision is not a nicety.

**C7. Close the loop, both directions.**
Downstream: did it land, was it understood. Upstream: what are residents actually
seeing. Lismore needed both.

**C8. Language-independent carriers.**
AWS icons and colours, maps, pictograms, audio in-language. A map of "where the water
is and where to go" needs no translation at all.

**C9. Anything pushed must be retractable.**
Grenfell. Conditions invalidate advice; the system must be able to say "that instruction
no longer applies".

**C10. Receiving, understanding and believing is not enough if someone can't act.**
Visa precarity, employer coercion, no car, no money for fuel. Feasibility of the advised
action is part of the message design.

---

## Part 3 — Where the opportunity is, for an 8-hour build

Judged on: evidence-backed problem, differentiation from existing solutions, demoable
in 2–3 minutes.

**Strongest ground — the comprehension and credibility layer.**
Delivery is being solved nationally right now by AusAlert ($132M, launching 1 Oct 2026).
Competing on delivery is a losing pitch. **Sitting on top of it is a winning one:**
take the alert that is already reaching every phone, and fix what happens next —
simplify it, translate it defensibly, make it actionable, and route it through people
the community trusts.

**High-value, under-served candidates**

1. **Plain-language + in-language rewriting of live warnings.** Take a real official
   warning; produce an Easy-English version, an in-language version, and a
   pictogram/map version, with the required action stated imperatively. Directly hits
   C1, C2, C8. Demos in 20 seconds with a real, ugly, real-world warning as the
   "before".
2. **Trusted-messenger relay.** Route official warnings to registered community leaders
   who confirm, annotate, and forward within their own networks — with the confirmation
   flowing back as delivery telemetry. Hits C4 and C7, and is the best-evidenced
   intervention in the file.
3. **Verified translation pipeline, not raw MT.** MT for speed + pre-approved emergency
   phrase bank + community verification, with an explicit confidence/verification state
   attached to every rendered message. Hits C3 and answers "no AI slop" head-on.
4. **Comprehension and delivery telemetry.** Give the agency a dashboard for
   *understood and acted on*, not just *sent*. Currently unsolved everywhere. Hits C7.
   Very strong on the "What does success look like?" criterion, since the KPI is built
   into the product.
5. **Community upstream reporting.** Structured resident observations feeding official
   situational awareness. The Lismore gap. Hits C7.

**What to be sceptical of**
- "An app that translates alerts" — fails the brief's own app-assumption critique.
- Anything whose core is a single call to a translation API — that is the "AI slop"
  outcome the brief warns against, and C3 says it is actively unsafe.
- Competing head-on with AusAlert on delivery.
- Undefined "diverse communities" — name the cohort.

---

## Backend implications (this branch)

If the solution lands anywhere in the space above, the backend likely needs:

- **Warning ingest** — accept an official warning (or a realistic fixture). Real
  candidates: BoM warnings feed, state agency feeds, or the Australian Warning System
  structure. **For an 8-hour build, fixture data from real archived warnings is the
  right call** — it demos identically and removes a live-integration risk.
- **A message-transformation pipeline** with the stages made explicit and inspectable:
  `raw → simplified (Easy English) → translated → verified → rendered per channel`.
  Making the stages visible is itself the demo: judges see *why* this is not "we called
  Google Translate".
- **A verification state model** — every rendered message carries whether it is
  machine-translated, template-matched, or human-verified, and this must be visible to
  the recipient. Non-negotiable per C3.
- **A pre-approved phrase bank** — emergency phrases with vetted translations, so the
  highest-stakes sentences never depend on live MT.
- **Multi-channel rendering** — the same message emitted as SMS-length text, long text,
  a pictogram/map payload, and audio-ready text. C5 and C8.
- **A feedback endpoint** — receipt, comprehension, and resident reports. C7.
- **Determinism for the demo.** Cache or fixture every external call. Venue wifi failing
  during the pitch is a real risk, and 20% of the mark is delivery.

Agree the API contract with the frontend owner **before** either side builds. That is
the merge risk, and it is the critical path.
