# Major issues

The issues below are grouped by the brief's four-step chain:
**receive → understand → believe → act**. Each is stated as a failure mode, with the
evidence behind it. Citations in [`sources.md`](sources.md).

## Baseline: who we are talking about

- **27.6%** of Australia's population was born overseas (2021 Census).
- **~5.5 million people (≈21.5%)** speak a language other than English at home.
- **872,206 people — 3.4% of the population — speak English "not well" or "not at
  all"**. That is the hard core of the problem: roughly the population of Canberra plus
  Newcastle, for whom an English-only warning is not a degraded signal but *no signal*.
- Proficiency varies enormously by community: **30.5%** of Vietnamese-at-home speakers
  reported not speaking English well or at all, versus **8.8%** of Punjabi speakers.
  A single "multilingual" strategy applied uniformly will badly misallocate effort.
- Among speakers of Australian Indigenous languages in Queensland, **9.3%** speak
  English "not well" or "not at all".

The brief's framing is important and correct: **being physically close is not enough**,
and low online presence is itself a risk factor.

---

## Stage 1 — RECEIVE

### 1.1 Alerts are broadcast in the majority language only
Most warning systems are built in the majority language, leaving CALD communities
unserved at the very first step. In the 2022 Victorian floods, emergency information was
delivered by staff and volunteers who overwhelmingly spoke only English, which rendered
radio, the VicEmergency app, and 000 effectively useless for many migrant workers.

Note the asymmetry that persists even in new systems: **AusAlert's public information
website is offered in 19 languages**, but that is the *website*, not the alert. The
translated content sits where you have to already know to go looking for it.

### 1.2 Channel monoculture — everything fails at once
Lahaina lost **power and cellular service** during the fire; sirens were never sounded;
the cell alert reached only part of the town. When every channel in the plan depends on
the same infrastructure, one event removes all of them simultaneously.

### 1.3 The app-download assumption
The brief names this explicitly. An app requires: owning a smartphone, having storage,
finding it, installing it before the event, granting notification and location
permission, and having it survive the phone being replaced. Each step sheds users, and
sheds them **non-randomly** — the people who fall out are disproportionately the people
at highest risk.

### 1.4 Delivery is not verified
Lismore: many residents simply never received the evacuation SMS. Lahaina: only part of
the town got the 4:16 pm warning. In both cases the sending agency believed the message
had gone out. **Nobody measured whether it landed**, so nobody escalated.

### 1.5 Institutional delay outweighs technical latency
Valencia is the proof: the forecast was correct and the alert system worked, but the
regional authority did not convene until 5 pm and did not send ES-Alert until after
8 pm. The bottleneck was **who was permitted to press the button**, not the wire.

---

## Stage 2 — UNDERSTAND

### 2.1 Jargon and text-heavy messages
The brief calls this out, and the Co-TEM research confirms it from the translators'
side: official messages "are sometimes flawed with jargons, ambiguity and lack of
clarity", which then **defeats translation downstream**. You cannot translate your way
out of a source message that was unclear to begin with.

### 2.2 Idioms and register do not survive translation
The canonical documented example, from Australian flood messaging:

> **"If it's flooded, forget it."**
> A Macedonian-speaking participant: *"This doesn't make sense in our language. Forget
> it is very informal in our language — we usually don't speak that way — it is not
> polite."*

A campaign slogan optimised for English-speaking recall becomes, on literal translation,
either meaningless or rude — and a message that reads as rude from an official source
damages trust as well as comprehension. **This one example is worth putting on a slide.**

### 2.3 Concepts, not just words, are missing
The brief's own example: "tsunami" carries no meaning for someone whose language and
lived environment have no such concept. Tōhoku shows the measurement version of the same
problem — "a 3 metre wave" only means "leave now" if you already know what 3 metres does
to your street.

### 2.4 Warning levels are an untranslated vocabulary
Australia's three-tier system (Advice / Watch and Act / Emergency Warning) encodes
urgency in English phrases. "Watch and Act" is internally contradictory to a literal
reader — is the instruction to watch, or to act?

### 2.5 Warnings state conditions, not actions
Pre-2011 Japanese tsunami warnings gave arrival time and wave height with little
instruction on what to do; they were rewritten afterwards into a directive register.
Descriptive warnings assume the recipient can perform the risk calculation themselves —
which requires exactly the local knowledge newcomers lack.

### 2.6 Only the headline hazard gets communicated
Black Summer messaging concentrated on the fire front, leaving a documented gap on
**smoke health risk** — the exposure that affected far more people, for far longer, with
language barriers named as a specific obstacle.

---

## Stage 3 — BELIEVE

### 3.1 Trust attaches to the messenger, not the message
The strongest positive finding in the evidence base: during COVID-19, **community
leaders and information intermediaries** were the effective last mile, reinterpreting
and vouching for official information inside their own networks. Conversely, distrust of
uniformed personnel is a documented barrier for some CALD communities — for people from
refugee backgrounds, a uniform may signal danger rather than help.

The brief's premise — *they do not trust information provided* — is the correct
diagnosis. A perfectly translated message from an untrusted source still fails.

### 3.2 Bad translation actively destroys credibility
COVID-19 translated materials in Australia were repeatedly criticised as inaccurate or
incoherent. The damage compounds: a visibly garbled official message teaches the
community that official messages are not worth reading. **Fast-and-wrong is worse than
slow-and-right**, which is a direct constraint on any machine-translation approach.

### 3.3 Warning fatigue and opting out
Peer-reviewed work on Wireless Emergency Alerts identifies **over-alerting** as a driver
of **warning fatigue**, with antecedents being **alert frequency, relevance, and message
content**, and symptoms including mental strain and emotional stress — leading users to
**opt out entirely**. Once someone disables alerts, no future improvement in message
quality reaches them.

Analogous evidence from clinical settings: **72–99% of clinical alarms are false**, and
the likelihood of a clinician accepting an alert **drops ~30% with each repetition**.

Relevance is the lever. A geographically over-broad alert is not merely useless to the
people outside the hazard — it is *actively harmful*, because it trains them to ignore
the next one.

### 3.4 Low risk perception
Valencia identified low public risk perception as a decisive co-factor: people received
information and did not read it as life-threatening. For a novel hazard (Cyclone Alfred
in Brisbane — first in 50+ years) there is no community memory to calibrate against, and
newcomers have none at all.

---

## Stage 4 — ACT

### 4.1 The advised action can be wrong, with no way to revoke it
Grenfell: "stay put" had effectively failed within ~30 minutes; residents were not told
to evacuate for over an hour. There was no mechanism to retract a standing instruction
people had been trained to follow.

### 4.2 The advised action can be physically impossible
Lahaina: fire crossed the Lahaina Bypass around 3:20 pm, closing a main route out.
People followed instructions into roads that no longer led anywhere.

### 4.3 Power and precarity prevent action
2022 Victorian floods: workers on temporary visas were told to stay on farms and ignore
road closures, and feared visa cancellation if they disobeyed. Temporary visa holders
also lack Medicare access, worsening outcomes afterwards. **Receiving, understanding,
and believing a warning is not sufficient when someone else controls whether you may
act on it.**

### 4.4 Post-impact service access is a separate, neglected need
Six months after the Türkiye–Syria earthquakes, affected people **still lacked
actionable information** on how to access services and faced physical barriers to
getting it. Undocumented and refugee populations drop out hardest here, because the
recovery system runs on paperwork and identity.

### 4.5 Recovery is where language barriers bite longest
Amnesty documented recovery volunteers unable to communicate past language and literacy
barriers, and inadequate document translation for insurance and compensation claims.
Warning gets the attention; **recovery is measured in months of compounding
disadvantage** and is comparatively wide open as a problem space.

---

## Cross-cutting

### 5.1 There is no upstream channel
Lismore: official gauges were broken or wrong while residents were watching the water
rise. Community knowledge existed and had nowhere to go. Systems are built one-way,
so the highest-resolution ground truth available is discarded.

### 5.2 Nobody closes the loop
Across every case, agencies could measure *messages sent*. None could measure
*understood* or *acted on*. Without that signal there is no way to detect a failing
channel during an event, and no way to improve between events.

### 5.3 The informal network does the work but gets no support
Lismore: **1,000+ rescues by neighbours in private boats**. COVID: community leaders as
the real last mile. The informal layer is consistently the effective one and is
consistently unsupported by the formal system — an obvious place to intervene.

### 5.4 The same lessons recur
Japan identified the multilingual information gap after Kobe in **1995** and stood up a
hotline; the same gap reappeared in **2011**. The Grenfell Inquiry found control-room
failures previously identified after an earlier fire. **Documented lessons are not the
constraint. Implementation is.** Any proposal should be honest about why it would
actually get adopted, since better ideas have failed to.
