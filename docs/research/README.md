# Preliminary research — Disaster & Emergency Management for CALD communities

Evidence base for the UQ Tech for Change 2026 pitch. Compiled 1 August 2026.
Problem Definition is 20% of the mark and is explicitly gated on evidence; Strategy is
50% and requires knowing what already exists. This is the material for both.

| Document | Contents |
| --- | --- |
| **[`philippines.md`](philippines.md)** | **Regional deep-dive — start here.** The Asia-Pacific community, hierarchy, connectivity, and the Haiyan terminology failure |
| [`case-studies.md`](case-studies.md) | 10 real disasters — what happened, what failed, what it teaches |
| [`issues.md`](issues.md) | Major issues, mapped to receive → understand → believe → act |
| [`existing-solutions.md`](existing-solutions.md) | What already exists, and precisely where it stops |
| [`opportunities.md`](opportunities.md) | Per-case counterfactuals → design constraints → 8-hour scope |
| [`sources.md`](sources.md) | Full citations, with accuracy cautions and open questions |

---

> **Brief updated 1 Aug 2026.** The community must now be **in the Asia-Pacific region**,
> and the brief adds **hierarchy in remote communities**, **connectivity**, **trust and
> accessibility**, and a concrete feature set. The Philippines research in
> [`philippines.md`](philippines.md) is the response to that; the Australian and
> international material below remains the comparative evidence base and is where the
> cross-cutting patterns come from.

## The one-paragraph argument

Across every disaster examined, the failure was **almost never sensing or forecasting**.
Valencia had a correct forecast, a working national alert system, and 223 deaths,
because the authority to send the alert sat in a different room from the knowledge that
it was needed. Lahaina had sirens, cell broadcast, and a written plan, and used none of
them successfully. Lismore's own river gauges were broken while residents watched the
water rise with no way to tell anyone. **The last mile — delivery, comprehension,
credibility, and the ability to act — is where people die, and it is the part nobody has
built.** For culturally and linguistically diverse communities, every one of those four
steps is harder, and the failures compound.

---

## The Philippines case, in five lines

1. **World's most disaster-prone country for 21 consecutive years** (WorldRiskIndex 2025,
   1st of 193, score 46.56). ~20 typhoons a year, ~20 earthquakes a day, **175 living
   Indigenous languages**.
2. **Haiyan, 2013.** The forecast was right, the warning was issued, people received it —
   and over 6,000 died, because the warning said **"storm surge"**, a term Waray-speaking
   residents did not know, while officials improvised translations on the fly. Survivors
   describe it as a **tsunami** — a word they already had.
3. **Odette, 2021.** 135 municipalities lost telecoms, 227 lost power, restoration took
   **two to eight weeks and longer in remote areas**. The national alerting law routes
   everything through mobile networks. **Offline-first is a requirement, not a feature.**
4. **Northern Cebu, 2025.** M6.9 earthquake on 30 September (74 dead); Typhoon Tino made
   landfall in the same corridor **five weeks later** (269 dead nationally). Compound
   disasters are the real operating environment.
5. **The structural opportunity.** Every Filipino barangay has a statutory, trusted local
   leader — the trusted-messenger layer Australia lacks. **It has no tooling.** That is
   the gap.

Full detail and community options in [`philippines.md`](philippines.md).

## Ten findings worth knowing cold

1. **872,206 people in Australia (3.4%) speak English "not well" or "not at all."**
   For them an English-only warning is not degraded — it is absent. 27.6% of the
   population was born overseas.

2. **"If it's flooded, forget it."** Australian research found this official flood
   slogan does not survive translation — a Macedonian-speaking participant reported it
   is meaningless and *impolite* in their language. One line, one slide, whole problem.

3. **Valencia, 2024.** AEMET's red warning was out that morning; the regional government
   did not convene until 5 pm and the ES-Alert did not go out until after 8 pm. 223
   dead. **The Japanese embassy, reading the same public data, warned its nationals a
   day earlier.** Same information, different actor, 24 hours of difference.

4. **Lahaina, 2023.** Sirens never sounded — the emergency manager feared people would
   read the tone as *tsunami* and run inland into the fire. The after-action report
   explicitly names communicating to "a transient tourist population that speaks
   multiple languages" as a core difficulty. 102 dead.

5. **Lismore, 2022.** Official gauges broken or transmitting bad data; many residents
   never got the evacuation SMS; one family called emergency services 35 times.
   **Over 1,000 people were rescued by neighbours in private boats.** The informal
   network worked; the formal one did not.

6. **Victorian floods, 2022.** Emergency information was delivered by staff who
   "overwhelmingly speak only English", rendering radio, the VicEmergency app **and
   000** effectively useless for migrant workers — some of whom were told by employers
   to ignore road closures, and feared visa cancellation if they refused.

7. **Trust runs on messengers, not messages.** Peer-reviewed Australian COVID-19 work
   found community leaders were the effective last mile. Meanwhile fast, poor-quality
   official translations actively damaged credibility. **Fast-and-wrong is worse than
   slow-and-right.**

8. **Japan already solved parts of this.** After 2011 it rewrote warnings from
   descriptive ("3 m wave expected") to imperative ("evacuate now"), and uses *Easy
   Japanese* — deliberately simplified language that serves every partial speaker with
   one artefact. Australia has not systematically done either.

9. **Over-alerting causes permanent opt-out.** Peer-reviewed WEA research ties warning
   fatigue to alert frequency, relevance and content. Once someone disables alerts, no
   future improvement reaches them. **Relevance is a safety feature.**

10. **AusAlert changes the board — right now.** Australia's $132M national cell-broadcast
    system was tested nationally on **27 July 2026** and launches **1 October 2026**,
    reaching every compatible phone with ~160 m targeting and no app required.
    **Delivery is being solved. Comprehension, credibility and the return path are not.**

---

## What this means for our pitch

Do not compete with AusAlert on delivery — build the layer above it. The defensible
positions, in order of evidence strength:

1. **Plain-language and in-language rewriting of live warnings** (fixes the source
   message first, states the action imperatively, uses language-independent carriers).
2. **Trusted-messenger routing** through community leaders — the best-evidenced
   intervention in this entire file.
3. **Verified translation, never raw machine translation** — with verification state
   visible to the recipient. This is also the honest answer to the brief's "no AI slop".
4. **Closing the loop** — measuring understood-and-acted-on, not just sent, and giving
   residents an upstream channel.

Full reasoning and 8-hour scoping in [`opportunities.md`](opportunities.md).

---

## Before anything goes on a slide

- **Open question that matters most:** does AusAlert broadcast *alerts* in languages
  other than English, or only host its *website* in 19 languages? My sources confirm
  only the latter. Verify with NEMA / ausalert.gov.au — our framing depends on it.
- Pull **Brisbane/Logan LGA language data** from ABS QuickStats to name a specific
  cohort. The brief penalises vague "diverse communities".
- Several entries in `sources.md` are secondary reporting of an inquiry. Check the
  primary document before quoting a number to judges.
- Accuracy cautions are flagged inline in the documents (Valencia alert timing, the
  Grenfell language-access claim). Respect them — a judge who catches an overstated
  claim costs more than the claim was worth.
