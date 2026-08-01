# Existing solutions and where they stop short

Know these before pitching. The 50% "Strategy/Solution" mark depends on showing *why
this is better than existing approaches* — which requires knowing what exists.
Citations in [`sources.md`](sources.md).

---

## 1. National / mass alerting infrastructure

### AusAlert (Australia) — the big one, live right now
- National cell-broadcast warning system replacing the old **Emergency Alert**
  SMS/voice system. Cost ~**$132M**.
- **National test conducted 27 July 2026**; official launch **1 October 2026**.
- Cell broadcast to all compatible devices attached to towers in a defined area, with
  geographic targeting quoted at **160 m accuracy**. No opt-in or registration; no
  reliance on holding a phone number list.
- Public information website available in **19 languages**. Designed in partnership with
  people with disability; resources in **Auslan, Easy Read, and closed captions**.
- Stakeholder workshops raised message accessibility, assistive-technology
  compatibility, **anxiety caused by unclear alerts**, and formats for low literacy.

**Where it stops short.** Cell broadcast decisively fixes *delivery* (issue 1.2/1.4) —
it does not require an app, a phone number, or an install. It does not fix
comprehension, translation of the alert payload, credibility, or the decision-to-send
delay that killed people in Valencia.

> **Verify before pitching.** My sources confirm the *website* is in 19 languages. I
> found **no confirmation that alert payloads themselves are multilingual**, or that
> broadcast language is selected by device locale. If AusAlert alerts are English-only
> at launch, that is a precisely-dated, nationally-relevant gap and the strongest
> possible framing for this hackathon. Check `ausalert.gov.au` and NEMA directly, and
> **do not claim it either way without checking.**

### Wireless Emergency Alerts (US) and ES-Alert (EU/Spain)
- Same cell-broadcast family. WEA supports Spanish-language alerts.
- **ES-Alert existed and worked in Valencia.** 223 people still died, because it was
  sent after 8 pm. Infrastructure without decision authority is not a warning system.
- WEA is also the system with the best-documented **warning fatigue and opt-out**
  research — the evidence that over-alerting causes people to disable alerts entirely.

### Sirens
- Lahaina: not activated, because a single tone meaning "something is wrong" was
  ambiguous between tsunami (go inland) and fire (do not go inland). **An
  undifferentiated signal is unusable when the required action differs by hazard.**

---

## 2. Australian warning standards and channels

### Australian Warning System (AWS)
- National three-tier framework: **Advice → Watch and Act → Emergency Warning**, with
  standardised colours and hazard icons across states and hazards.
- **Strength:** the icons and colour ramp are **language-independent**. This is an
  existing, official, nationally-consistent visual vocabulary that any solution can
  build on rather than invent — reuse it.
- **Weakness:** the tier *names* are English idiom ("Watch and Act"), and the underlying
  advice text is long-form English prose.

### State channels
- **Queensland:** Get Ready Queensland, `disaster.qld.gov.au`, council-run Disaster
  Dashboards.
- **NSW:** Hazards Near Me app; **Victoria:** VicEmergency app.
- **ABC Emergency** as designated national emergency broadcaster; **SEWS** alert tone.
- **Weakness:** app-dependent (issue 1.3), English-first, and — per Amnesty — delivered
  by an overwhelmingly English-speaking workforce. Amnesty also found **no state-wide
  consistency** in language support; it varied by municipality.

---

## 3. Translation and plain-language approaches

### Static translated resource libraries
Red Cross, state agencies, and councils publish translated preparedness PDFs and
fact sheets.
- **Weakness:** prepared in advance, generic, and **not connected to live warnings**.
  They tell you what a flood is; they cannot tell you that *this* creek is rising *now*.
  There is a documented gap between "translated resources exist" and "poor access to
  translated resources during crises".

### Easy Japanese / やさしい日本語 (Japan)
- Post-Kobe/post-3.11 practice of writing emergency information in **deliberately
  simplified Japanese** — short sentences, controlled vocabulary, no idiom.
- **Why it matters:** it serves everyone with partial proficiency in *one* artefact,
  rather than requiring N translations. It also helps low-literacy native speakers,
  children, and people under acute stress (where reading comprehension degrades).
- **This is the highest-leverage idea in the whole evidence base and it is
  under-applied in Australia.** "Easy English" exists; it is not systematically applied
  to live warning payloads.

### Safety Tips (Japan)
- Japan Tourism Agency app pushing disaster alerts in **14 languages** including
  English, Chinese, Korean, Spanish. Plus multilingual dictionaries and information
  sites.
- **Weakness:** it is an app, aimed largely at tourists; research notes a comprehensive
  evacuation strategy for international visitors remains limited.

### Directive-register rewriting (Japan, post-2011)
- Warnings deliberately rewritten from descriptive ("3 m wave expected") to
  **imperative** ("evacuate now"). Cheap, proven, and directly addresses the "act" step.

### Co-TEM — Collaborative Translation of Emergency Messages (Australia)
- Ogie & Perez, University of Wollongong. First Australian empirical study of how CALD
  communities respond to state emergency service messages.
- Proposes **trained citizen translators** from CALD communities translating official
  warnings, with community verification. Found feasible.
- Surfaced the **"If it's flooded, forget it"** failure.
- **Key finding to respect:** Co-TEM is threatened by the *source* messages themselves
  being jargon-laden and ambiguous. **Fix the English first, or you are translating
  mud.**
- **Weakness:** human-in-the-loop translation has latency, and volunteer availability at
  3 am during the event is exactly when it is needed and least available.

### Machine translation
- Google Translate, NLLB, LLM translation. Instant, free, huge language coverage.
- **Weakness, and it is severe:** the COVID-19 Australian experience is a documented
  case of fast translation producing incoherent official material that **damaged
  trust**. Low-resource languages, Indigenous languages, and emergency-specific register
  are exactly where MT is weakest — and exactly where the need is greatest. Raw MT
  piped into a live warning is a credibility risk, not a solution.
- The defensible pattern is **MT + community verification + pre-approved templates**,
  not MT alone. Given the brief's "no AI slop" instruction, a proposal that is just
  "we call a translation API" will be marked down.

---

## 4. Community-led and social approaches

### Community leaders as information intermediaries
- Peer-reviewed Australian COVID-19 finding: community leaders were the effective last
  mile for reaching multicultural communities. **The most evidence-backed intervention
  in this document.**

### Multilingual hotlines
- Post-Kobe 1995: volunteer-run 24-hour multilingual hotline for residents cut off from
  information. Low-tech, no app, works on any phone. Still relevant.

### Multicultural broadcasting
- SBS radio/TV in-language emergency broadcasting; community and ethnic radio.
- **Strength:** reaches people with no smartphone and no online presence — the exact
  cohort the brief names. **Weakness:** broadcast, so not geographically targeted, and
  not on-demand.

### Preparedness workshops with migrant/refugee communities
- FRNSW multicultural fire safety programs; ACT workshops for diverse residents; AJEM
  work on migrant and refugee communities strengthening disaster resilience.
- **Weakness:** preparedness-phase only, small reach per unit of effort, and dependent
  on ongoing funding.

### Translators without Borders / CLEAR Global
- Rapid-response humanitarian translation, crisis glossaries, language data.

### CDAC Network / IFRC Community Engagement and Accountability
- Maps the information-and-communication ecosystem in a disaster and treats
  **information as aid in its own right**. Ran exactly this exercise for Türkiye and
  northwest Syria after 2023.

---

## 5. Summary — what is genuinely unsolved

| Need | Solved by | Status |
| --- | --- | --- |
| Deliver to every phone without install | AusAlert / cell broadcast | **Solved** (AU, from Oct 2026) |
| Consistent visual severity language | AWS icons and colours | **Solved**, reusable |
| Translated *preparedness* material | Red Cross, state agencies | Solved but static and disconnected |
| Simple-language warning text | Easy Japanese | Proven overseas, **under-applied in AU** |
| Directive "what to do now" phrasing | Japan post-2011 | Proven, cheap, **not standard in AU** |
| Translating *live* warnings | Co-TEM (pilot); nothing operational | **Largely unsolved** |
| Trusted-messenger delivery | Ad-hoc community leaders | **Unsolved / unsupported** |
| Relevance targeting to prevent fatigue | Partial (geo-targeting) | Weak |
| Verifying receipt / comprehension | — | **Unsolved** |
| Upstream community ground truth | — | **Unsolved** |
| Post-impact service-access info | — | **Weak** (Türkiye finding) |
| Recovery-phase language support | — | **Weak** (Amnesty finding) |

The bottom half of that table is where the marks are. Delivery is a solved problem being
re-solved nationally at a cost of $132M; **comprehension, credibility, and the return
path are not.**
