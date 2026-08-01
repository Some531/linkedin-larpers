# Regional deep-dive: the Philippines

The updated brief requires a **clearly defined culturally and linguistically distinct
community in the Asia-Pacific region**, and asks us to address **hierarchy in remote
communities**, **connectivity**, and **trust**. This document is the evidence base for
choosing the Philippines, and for choosing a specific community within it.

Citations in [`sources.md`](sources.md). Confidence labels as in
[`case-studies.md`](case-studies.md).

---

## 1. Why the Philippines

| Fact | Figure |
| --- | --- |
| WorldRiskIndex 2025 rank | **1st of 193 countries**, score **46.56 ("very high")** |
| Consecutive years ranked most at-risk | **21** |
| Typhoons entering Philippine territory per year | **~20** |
| Earthquakes per day (all magnitudes) | **~20** |
| Living Indigenous languages | **175**, of which **59 are endangered** |
| Highest-risk provinces | Cagayan (88.10), Agusan del Norte (87.51), Pangasinan (85.19), Pampanga (83.49), Maguindanao (82.94), Metro Manila (81.12) |

The country sits on both the **Pacific Typhoon Belt** and the **Ring of Fire**. River
and coastal flooding are the dominant hazards.

This is the strongest possible setting for this brief: extreme hazard exposure,
extraordinary linguistic diversity, a formal governance hierarchy that reaches down to
the street, and infrastructure that reliably fails during the events it is meant to
serve. Crucially, the failures are **documented, recent, and specific** — not
speculative.

---

## 2. Case studies

### 2.1 Super Typhoon Haiyan / Yolanda — 8 November 2013 **[peer-reviewed]**

**The single best-evidenced example of the brief's core thesis anywhere in the world.**

**What happened.** One of the strongest tropical cyclones ever recorded at landfall
struck the Eastern Visayas. Tacloban City was destroyed by a storm surge. Over 6,000
confirmed dead; totals including the missing are commonly given as over 7,300.

**What failed — the warning was received, and it was not understood.**

- PAGASA issued warnings. People **knew a typhoon was coming** and knew the warnings
  existed. They expected **strong winds and heavy rain**. They did not expect water.
- The warnings used the English technical term **"storm surge"**. Research on the
  Haiyan early warning system found that **local residents did not understand what a
  storm surge was** — the term was, for many, newly introduced to their vocabulary by
  this event.
- Local officials were **translating on the fly**: they had PAGASA/NDRRMC advisories in
  front of them in English and rendered them into **Waray** while speaking to residents.
  Analysis found the process "transmitted and retransmitted the same routine text"
  rather than communicating authentic meaning. There was no pre-agreed Waray equivalent
  to reach for, under time pressure, in the dark.
- A **PAGASA assistant weather services chief conceded afterwards** that more could have
  been done to explain the magnitude and gravity of a storm surge — "the storm surge
  wasn't explained there."
- Consequence: people understood the warning to mean an ordinary bad typhoon, a thing
  Eastern Visayas residents have survived many times. **They underestimated it and did
  not evacuate in time.**
- Telling detail: **many survivors, describing what hit them, call it a tsunami** — a
  word they *did* have and *did* understand. Comparative research found tsunami
  awareness in the Philippines exceeded storm surge awareness before Haiyan.

**Why this matters for us.** The brief says: *"people from different backgrounds may not
understand terms like 'tsunami' in their native language (meaning lost through
translation)."* Haiyan is the mirror image and it is far stronger evidence: the
population **had** a word for the thing that killed them, and the warning system used a
different one. Every technical component worked. The forecast was accurate, the warning
was issued, it was disseminated, and it reached people. **Over 6,000 died at the
"understand" step of the chain.**

**What was done afterwards.** PAGASA worked with **linguists** to make hazard
terminology comprehensible in local languages, and committed to simplifying storm surge
and related terms. This is important for our pitch in two ways: it confirms the
diagnosis officially, and it establishes that **terminology work is an accepted,
precedented intervention** — we are not proposing something exotic.

---

### 2.2 Super Typhoon Rai / Odette — 16 December 2021 **[reported]**

**The connectivity case.** The brief explicitly asks us to think about connectivity.
This is the answer.

- **135 cities and municipalities lost telecommunications.** Ten days later, 40 were
  still dark — and officials said the outage made it *difficult to even assess the
  damage*, because the reporting channel was the thing that had broken.
- **227 cities/municipalities lost power.** Four days after landfall, only **9% (21
  municipalities) had been restored**.
- Over **1.7 million electricity customers** lost power. Full restoration took **two to
  eight weeks** in several provinces, and **longer in remote areas**; NDRRMC projected
  full restoration into **February 2022** — roughly two months.
- Cause of telecom outage per Globe: **multiple fibre cuts and lack of commercial
  power.** NGCP recorded 95 downed facilities including 12 towers and 820 transmission
  poles.
- Hardest hit: Siargao, Dinagat Islands, Surigao City, southern Leyte, Cebu — islands
  and remote coasts, i.e. exactly the hard-to-reach communities in scope.

**Why this matters.** The Philippines' national alerting law (RA 10639) mandates alerts
**through mobile networks**. Odette demonstrates the structural flaw: a severe typhoon
destroys the towers and the power that the alert system depends on. And the failure is
not symmetrical in time — the network is up for the *warning* phase and down for the
entire *response and recovery* phase, which is when people need to find water, medical
care, missing relatives, and aid.

**Design consequence, and it is non-negotiable:** anything we build must have a defined
behaviour when there is no signal and no mains power for weeks. An app that requires
connectivity to be useful is useless in the phase where Filipinos die of secondary
causes. **Offline-first is a requirement here, not a feature.**

---

### 2.3 The 2024 season — six typhoons in 30 days **[reported]**

Gaemi (Carina), Yagi (Enteng), Trami (Kristine), Man-Yi (Pepito) and others struck in
rapid succession; **six typhoons hit within a 30-day window**. The Philippines ranked
**7th most affected country by extreme weather in 2024**.

**Why this matters.** This is warning fatigue as lived reality, not theory. A population
receiving evacuation warnings weekly, for storms of wildly varying severity, while
still displaced from the last one, is being asked to make a costly decision repeatedly.
The peer-reviewed finding from `issues.md` — that **alert frequency and relevance drive
warning fatigue and opt-out** — applies to the Philippines more acutely than almost
anywhere. **Any solution that increases message volume without increasing relevance
will make outcomes worse.**

---

### 2.4 Bogo City / Northern Cebu earthquake — 30 September 2025 **[inquiry]**

- **M6.9**, epicentre ~19 km from Bogo City, Cebu, at just **5 km depth** — shallow and
  destructive. Struck at **9:59 PM**, in the dark.
- **74 dead, 559 injured**, ~740 damaged structures, **~748,000 people affected**.

**Why this matters.** No warning is possible for an earthquake. The entire information
problem shifts to the minutes and days *after* impact: is my building safe, is there a
tsunami risk, where is help. It is a clean argument for why a solution must cover
**response and recovery**, not just pre-event warning — and it shows why the map,
elevation and landmark features in our brief matter (nearest hospital, is my location
above tsunami risk elevation).

---

### 2.5 Typhoon Tino (Kalmaegi) and Super Typhoon Uwan (Fung-wong) — November 2025 **[inquiry]**

- **Tino** entered on 2 November 2025, intensified fast, and made **multiple landfalls**:
  Silago (Southern Leyte), **Borbon (Cebu)**, Sagay City (Negros Occidental), Iloilo
  City, El Nido (Palawan).
- **269 dead, 523 injured, 113 missing** — the deadliest cyclone of 2025. Damage
  **≥US$588 million**. The World Bank released **US$500 million** in response.
- **Uwan** followed within days: sustained winds of **185 km/h** across Southern Tagalog
  and Central Luzon. Combined toll from the two storms exceeded 250 dead.

**The detail that should be on a slide: Tino made landfall at Borbon, Cebu — roughly
five weeks after the M6.9 earthquake struck Bogo City, in the same northern Cebu
corridor.** Communities still in tents, with structures already weakened and trust in
official reassurance already damaged, were hit by the deadliest typhoon of the year.

**Why this matters.** Compound and cascading disasters are the real operating
environment, and they are getting more common. A system that models "a disaster" as a
discrete event with a start and an end will misrepresent what these communities
actually live through. It also raises the "believe" problem sharply: what does an
official all-clear mean to someone whose house was declared safe five weeks ago?

---

### 2.6 Mount Pinatubo — June 1991 **[peer-reviewed]** — *the success case*

Include this. A pitch that only shows failure is less persuasive than one that shows
**what works and why**.

**What happened.** A VEI-6 eruption, one of the largest of the 20th century.
**Approximately 400 direct deaths** — remarkably low.

**What worked.**
- PHIVOLCS and USGS declared a danger zone in **April 1991**, two months ahead, and
  evacuated **~20,000 Aeta** from the slopes.
- **82% of those forewarned took protective action**; **46% evacuated promptly.**
- Warnings were **coupled with strong visible clues** from pre-climactic eruptions —
  people could see the thing the warning described. Warning plus visible confirmation
  produced belief; warning alone rarely does.

**What still failed, and it is the recovery lesson.**
- Some Aeta **refused to leave** and sheltered in caves; they died in pyroclastic flows.
- **~20,000 Aeta were permanently displaced**, most still in resettlement camps long
  afterwards. The eruption caused "immediate and sustained disconnection of traditional
  knowledge from the biological resources" needed to practise it — the disaster severed
  an Indigenous knowledge system from the land that sustained it.

**Why this matters.** Two lessons. First, **long lead time plus visible confirmation
plus sustained engagement with a specific Indigenous community produced 82% compliance**
— the "believe" step solved in practice. Second, the response was a success and the
**recovery was a decades-long failure**, which is the strongest available argument for
the brief's recovery phase.

---

### 2.7 Mamanwa Indigenous knowledge after Haiyan — Basey, Samar **[peer-reviewed]**

Research on the **Mamanwa** Indigenous people documented local-Indigenous knowledge for
disaster risk reduction after Haiyan. The broader Philippine literature finds that
disaster-affected Indigenous communities hold **time-tested knowledge and coping
practices** developed from close connection to their environment, and that upland
communities already integrate Indigenous knowledge into early warning.

**Why this matters.** It reframes the design. The deficit is *not* that these
communities lack risk knowledge — they often have highly localised knowledge the
national system does not. The deficit is that **information flows one way**, and their
knowledge has nowhere to go. This is the same gap as the broken Lismore gauges, and it
points directly at a two-way design.

---

## 3. Language, hierarchy, and trust

### 3.1 Language
- **175 living Indigenous languages; 59 endangered.**
- Filipino (Tagalog-based) is the national language, but **it is not everyone's first
  language**, and comprehension of technical registers in a second language degrades
  sharply under stress.
- Haiyan-affected Eastern Visayas is **Waray**-speaking; much of the Visayas and
  Mindanao is **Cebuano/Bisaya**. National-level warning content is produced in English
  and Filipino, leaving a translation step that — per Haiyan — was being improvised by
  individual officials during the event.

**Implication.** "Support several languages" (per the feature list) is not a dropdown
with Spanish and French in it. For the Philippines it means choosing a **small number of
specific languages** — realistically Waray, Cebuano, Filipino, English for a Visayas
focus — and getting the **hazard terminology** right in each, which is the part Haiyan
proves is hard and lethal.

### 3.2 Hierarchy — the brief asks us to address this directly

The Philippines has an unusually **legible governance hierarchy** running to the
smallest unit:

```
National (NDRRMC, PAGASA, PHIVOLCS)
  → Region → Province → City/Municipality (LDRRMO)
    → BARANGAY (BDRRMC, Barangay Captain, tanod)
      → Purok / sitio → household
```

- The **barangay** is the smallest administrative unit and is described in the
  literature as a **critical partner of national government**, with defined DRRM
  responsibilities.
- In Indigenous communities, a **customary authority structure** (elders, tribal
  chieftains/datu, IPMRs) runs alongside the formal barangay structure, and is often the
  one that carries actual legitimacy.
- Documented gap: research identifies the **absence of information systems in small
  communities**, weak early-warning dissemination, and lack of training on what to do —
  as a complex, persistent problem in most local communities.

**Implication, and this is the strategic insight for the pitch.** The Philippines
already *has* the trusted-messenger layer that Australia lacks — a named, known,
locally-legitimate person in every barangay. The COVID-19 finding from `issues.md` (that
**community leaders are the effective last mile**) is not a hypothetical here; the
structure exists in law. **What is missing is the tooling for that layer.** The barangay
captain is currently receiving English technical text and improvising a translation
under pressure, exactly as Haiyan documented.

That is a far more credible product than "an app for residents", and it directly answers
the brief's questions about hierarchy, trust, and practical operation.

### 3.3 Trust
- Pinatubo shows what earned trust looks like: **sustained pre-event engagement with a
  specific Indigenous community, over months, with visible corroboration** → 82%
  protective action.
- Haiyan shows the cost of the reverse: after a warning that people followed and that
  still left their families dead, official credibility is spent. Compound events
  (2.5) spend it repeatedly.

---

## 4. Connectivity — the practical constraint

From Odette (2.2), the planning assumptions must be:

| Phase | Realistic connectivity |
| --- | --- |
| Days before | Mostly functional — mobile, TV, radio, barangay announcement |
| Hours before | Degrading; power precautionary shutdowns |
| Impact | **Towers and power down. Assume nothing works.** |
| Days 1–14 after | Patchy; some municipalities fully dark for weeks |
| Weeks 2–8 after | Progressive restoration; **remote areas last** |

Plus: RA 10639 routes national alerting **through mobile networks** — one dependency,
and the OECD/ASEAN review specifically criticises this **over-reliance on
telecommunications, leaving gaps in multi-channel communication**.

**Design consequences.**
- **Pre-load, don't fetch.** Maps, evacuation routes, landmark locations, hazard
  explainers and phrase content must be on the device *before* impact.
- **SMS/cell broadcast over data** where a network exists — the brief's SMS-first
  feature is the right instinct and is well supported by this evidence.
- **Define offline behaviour explicitly** — what the map, the risk classification and
  the chatbot do with no signal. A chatbot that requires a live API call is dead in the
  phase it is most needed; a pre-loaded terminology/FAQ pack is not.
- **Analogue fallbacks matter**: printed pictogram cards at the barangay hall, battery
  radio, the barangay captain with a megaphone. Not a cop-out — this is what actually
  runs in week one.

---

## 5. Existing solutions in the Philippines

| System | What it does | Where it stops |
| --- | --- | --- |
| **PAGASA** (weather) | Satellite tracking, storm path prediction, ground sensors, cell broadcast. Described as one of the developing world's more sophisticated EWS. | Technical register; Haiyan showed comprehension failure downstream |
| **PHIVOLCS** | Earthquake/volcano monitoring and advisories | No warning possible for earthquakes; post-event info gap |
| **RA 10639** — Free Mobile Disaster Alerts Act (2014, IRR 2015) | **Mandates telcos to send free, location-specific alerts** near affected areas, at intervals set by NDRRMC/PAGASA/PHIVOLCS | Single-channel dependency on mobile networks (Odette); nothing mandates *comprehensibility* or *language* |
| **Project NOAH** | Real-time flood prediction maps using LIDAR terrain and rainfall models | Technical/portal-based; open hazard data we can build on |
| **Barangay DRRM (BDRRMC)** | Statutory local structure, trusted local figures | Under-resourced; **no tooling for the translation/explanation task** |
| **Community-based DRRM & Indigenous EWS** | Upland communities integrate Indigenous knowledge into local early warning | Localised, not connected upward; documented absence of information systems in small communities |
| **PAGASA + linguists (post-Haiyan)** | Simplifying hazard terminology in local languages | Confirms the diagnosis; the *last-mile delivery* of that plain language is still improvised |

**The gap, stated plainly.** The Philippines has good science, a legal alerting mandate,
open hazard data, and a statutory trusted-messenger structure in every barangay. **What
it does not have is the layer that turns an English technical warning into something a
Waray-speaking fisherman believes and acts on — and there is a body count attached to
that gap.** That is a defensible, evidence-backed problem statement, and it is the
50%-weighted Strategy criterion.

---

## 6. How this maps to the feature set in the brief

| Brief feature | Philippine evidence that justifies it | Sharpening |
| --- | --- | --- |
| **Live map, 1 km radius, landmarks, elevation** | Cebu 2025 (post-quake orientation); Haiyan surge (elevation is *exactly* the storm-surge question) | **Must be pre-cached offline.** Use OpenStreetMap + Project NOAH / NAMRIA hazard layers. Frame elevation as "is the water going to reach me", not a number in metres |
| **Risk determination from government data** | PAGASA, PHIVOLCS, Project NOAH are open and real | Use real PH sources, not ABS — the brief's ABS mention was written pre-Asia-Pacific |
| **Chatbot for unfamiliar terms** | **This is the Haiyan intervention.** "What is a storm surge" is the question that killed 6,000 people | Must work offline for core hazard terms — a pre-loaded glossary in Waray/Cebuano/Filipino beats a live LLM call. Answer in *analogy*, not definition |
| **SMS risk classification, traffic-light, emoji, phase-explicit** | RA 10639 already mandates free SMS alerts; Odette proves data will be down | Strongest feature in the list. Phase-explicit ("this is happening NOW") directly addresses Haiyan's underestimation |
| **Symbols / pictograms** | 175 languages — symbols scale where translation cannot | Reuse an existing icon vocabulary rather than inventing one; test comprehension, don't assume it |
| **Accessibility, TTS, large text** | Elderly are over-represented in typhoon deaths; literacy varies | TTS **in the local language** is the high-value version — it also serves non-readers, which translation alone does not |
| *(missing)* **Barangay-official tooling** | §3.2 — the hierarchy exists and is currently improvising translation under pressure | **Consider adding.** Strongest differentiator; directly answers the brief's hierarchy question |
| *(missing)* **Upstream community reporting** | §2.7 Mamanwa; the one-way flow problem | Closes the loop; Indigenous knowledge has somewhere to go |

---

## 7. Candidate communities to define

The brief requires a **clearly defined** community. Options, strongest first:

1. **Waray-speaking coastal communities of Eastern Visayas (Tacloban / Basey, Samar).**
   Directly tied to the best-documented failure in the file. ~2.6 million Waray speakers.
   Named language, named hazard, named terminology failure, named fix.
2. **Cebuano/Bisaya-speaking communities of northern Cebu (Bogo, Borbon, Medellin).**
   Hit by the M6.9 earthquake *and* Typhoon Tino within five weeks — the compound-disaster
   story, and the most recent evidence available.
3. **Mamanwa or Aeta Indigenous communities.** Strongest on the hierarchy, Indigenous
   knowledge, and recovery dimensions. Requires care: speaking *about* an Indigenous
   community without consultation is a real risk, and judges may probe it. Handle with
   humility or pick 1 or 2.

**Recommendation: option 1 or 2.** Both give a named language, a named hazard, a named
geography, and documented deaths traceable to a communication failure — which is exactly
what "Problem Definition supported by evidence" is asking for.

---

## 8. The pitch line

> In 2013, PAGASA correctly forecast Typhoon Haiyan and issued warnings. People received
> them. Over 6,000 died anyway — because the warnings said **"storm surge"**, a term
> Waray-speaking residents had never heard, and local officials were left translating
> English technical text on the fly. Survivors describe what hit them as a **tsunami** —
> a word they already had, and would have run from.
>
> The Philippines has been the world's most at-risk country for **21 consecutive
> years**. It has good science, a law mandating free disaster SMS, and a trusted leader
> in every barangay. What it does not have is the layer between the forecast and the
> fisherman.
