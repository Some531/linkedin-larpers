# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

Team **linkedin-larpers**, competing in the **UQ Tech for Change 2026** hackathon.
One day (8 hours) to design a solution, build an MVP, and pitch it.

**Theme: Disaster and Emergency Management**, specifically for **culturally and
linguistically diverse (CALD) and hard-to-reach communities** — people who are
physically present in a warning zone but effectively invisible to the warning system.

The community must be **in the Asia-Pacific region** and clearly defined. Working
assumption: **the Philippines** — see [`docs/research/philippines.md`](docs/research/philippines.md)
for why, and for the candidate communities.

Judging rubric (this drives every decision):

| Criterion | Weight |
| --- | --- |
| Problem Definition (supported by evidence) | 20% |
| Strategy / Solution | 50% |
| What Does Success Look Like? | 10% |
| Delivery and Presentation | 20% |

Note the shape of that rubric: **70% is problem + solution**, and problem marks are
explicitly gated on *evidence*. Unsourced claims cost marks. See `docs/research/`.

## The four-step chain

The brief defines a message as only successful if the recipient does all four:

**receive → understand → believe → act**

Any feature, slide, or line of code should be traceable to a step in that chain.
If it isn't, it is decoration. Most existing systems only solve *receive*.

## Disaster phases

Prevention · Preparedness · **Response** · Recovery

We may span more than one phase but must state a primary focus. Say which one
explicitly in the pitch — the brief asks for it.

## Hard constraints from the brief

- **No AI slop.** The brief says this in as many words. Generic LLM-generated prose,
  fake statistics, and "AI-powered" hand-waving will be marked down. Every number in
  a deliverable needs a source. If a figure can't be sourced, cut it or label it as
  an estimate.
- **Don't assume app installs.** "Response information often comes through apps, there
  is an assumption that people download those apps." A solution whose first step is
  "the user downloads our app" fails the brief on its own terms.
- **Define the community.** Vague "diverse communities" scores badly. Name a specific
  cohort (e.g. Queensland Pacific Islander seasonal workers, recently-arrived
  Vietnamese-speaking residents in Brisbane, remote Indigenous communities).
- **Psychological and social factors count**, not just technology. Trust, warning
  fatigue, and information overload are in scope.
- **Translation is not the whole problem.** Meaning is lost through translation
  (e.g. "tsunami", "watch and act" have no clean equivalent in many languages).
- **Address hierarchy in remote communities.** In the Philippines that means the
  barangay structure and, for Indigenous communities, customary authority alongside it.
- **Connectivity is a hard constraint, not a caveat.** Typhoon Odette (2021) left 135
  municipalities without telecoms and took two to eight weeks to restore power, longer
  in remote areas. **Assume no signal and no mains power for the response phase.**
  Every feature needs a defined offline behaviour.
- **The solution must be based on a community need**, and the brief asks how it would
  operate practically, and what alternatives were considered. Answer all three.

## Feature set from the brief

The brief now names features. Treat these as the intended direction, and see
`docs/research/philippines.md` §6 for how each is justified and where to sharpen it.

- **Live map** — location permission, ~1 km radius, zoom, highlighted landmarks
  (hospitals), elevation used for personalised tsunami/surge risk. Open-source data.
- **Risk determination** — government/open datasets for the user's country and region,
  plus personal location, producing personalised plans. *For the Philippines this means
  PAGASA, PHIVOLCS and Project NOAH — not the ABS.*
- **Chatbot** — for navigation questions and for explaining unfamiliar terms. *This is
  the Haiyan intervention: "what is a storm surge" is the question that killed 6,000
  people. It must work offline for core hazard terms.*
- **Accessibility** — enlarged text, disability and elderly support, several languages,
  text-to-speech.
- **Risk classification SMS** — traffic-lighted, emoji to denote hazard type, explicit
  about which phase it refers to (imminent vs happening now), concise and jargon-free,
  with a link to the app for detail.
- **Symbols** to convey meaning where language cannot.

## Repository layout

```
README.md              Brief, branch assignments, assessment criteria (source of truth)
Idea Prompting         Original ideation + team execution prompts
CLAUDE.md              This file
docs/research/         Evidence base — read before proposing anything
  README.md              Index and executive summary
  philippines.md         Asia-Pacific deep-dive: community, hierarchy, connectivity
  case-studies.md        Real disasters, what failed, sourced
  issues.md              Major issues mapped to receive/understand/believe/act
  existing-solutions.md  What already exists and where it stops short
  opportunities.md       What could have improved outcomes → design implications
  sources.md             Full source list
```

## Branches

| Branch | Owner | Scope |
| --- | --- | --- |
| `main` | shared | Brief, merged work |
| `imira` | Imira | **Backend** — this branch |
| `hamza` | Hamza | Frontend |
| `swornim` | Swornim | Idea generation, plan formulation |

Backend and frontend are built separately, then merged. That means the **API contract
is the critical path** — agree it early and write it down before either side builds
against it, or the merge at hour 6 will fail.

Work on `imira`. Open a PR into `main`; don't push directly to `main` or to other
people's branches.

## Working conventions

- **Evidence first.** When making a factual claim about a disaster, a statistic, or an
  existing system, cite it. Add new sources to `docs/research/sources.md`.
- **Flag uncertainty.** If a figure is contested or the source is secondary, say so
  inline. A qualified number survives a judge's question; a confident wrong one doesn't.
- **8-hour scope discipline.** Prefer something demoable end-to-end over something
  architecturally impressive and half-wired. When a feature is proposed, state whether
  it is must-have, nice-to-have, or first-to-cut.
- **Demo-ability is 20% of the mark.** Backend work that produces nothing visible on
  screen is worth less than backend work that does, regardless of how good it is.
- Keep secrets out of the repo; use `.env` (git-ignored) and document required vars.

## Stack

Not yet chosen. Decide with the frontend owner before writing application code, and
record the decision plus the API contract here once made.

Constraints to weigh: 8-hour build, must demo live and offline-tolerantly (venue wifi
is a real risk), and the frontend must be able to integrate against it quickly.
