# HandaPH — iOS client

"Handa" is Tagalog for *ready / prepared*. This is the depth layer of the
three-plane architecture in [`docs/architecture.md`](../docs/architecture.md):
SMS reaches every handset; the link in the SMS opens this app for detail.

## Build

Requires Xcode 16+ (iOS 17 SDK). `HandaPH.xcodeproj` is committed, so:

```sh
open ios/HandaPH.xcodeproj
```

The project file is *generated* from `project.yml`. If you add/remove files
or targets, edit `project.yml` and regenerate rather than editing the
project in Xcode's UI:

```sh
brew install xcodegen   # once
cd ios && xcodegen generate
```

Run the UI smoke tests (first-run language flow, SMS deep link, glossary
search) with Cmd-U, or:

```sh
xcodebuild -project HandaPH.xcodeproj -scheme HandaPH \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```

No external packages — the first cut builds with the system SDK only.

## Anthropic API key (Gabay assistant)

Put your key in `ios/Config/Secrets.local.xcconfig` (git-ignored):

```
ANTHROPIC_API_KEY = sk-ant-...
```

Rebuild (⌘R). With a key, Gabay answers via Claude, grounded on the verified
glossary and instructed to never compose warnings. Without one — or offline —
it answers directly from the on-device corpus, deterministically. Demo note:
a key inside an app binary is hackathon-grade; production proxies through the
backend.

## Demo the deep link

The SMS in the pitch ends with `rdy.ph/a/7Kq2`. Universal Links need a served
`apple-app-site-association`, so the demo uses the custom scheme until the
domain is live. In Simulator:

```sh
xcrun simctl openurl booted "handaph://a/7Kq2"
```

That opens the storm-surge alert detail directly — the SMS → app moment.

## Deliberate decisions (read before "fixing")

- **MapKit, not MapLibre — for now.** `docs/architecture.md` specifies
  MapLibre + offline PMTiles. MapKit is used in this cut so the project builds
  with zero dependencies on day one; `HazardMapView` is the single file to swap.
- **No LLM anywhere.** All alert and glossary text comes from
  `FixtureStore`, standing in for the versioned template bank served by the
  FastAPI backend. The assistant retrieves; it never generates.
- **Honest translations.** Every non-English string carries a
  `TranslationState`. Anything not verified by a community reviewer renders
  with an "awaiting community verification" chip. Do not add translations
  without marking their state.
- **Offline-first.** Everything renders from bundled fixtures with the radio
  off. `APIClient` is the stub for the OpenAPI contract; sync layers on top,
  never replaces the local store.
- **Swift 5 language mode** to keep the hackathon build unblocked; the code is
  written to migrate cleanly (`@MainActor` on observable state, value types).

## Accessibility commitments

- Dynamic Type throughout — no fixed font sizes; an extra "larger text"
  boost in Settings for elderly users on top of the system setting.
- Severity is never colour alone: colour + emoji + SF Symbol + words.
- Text-to-speech on every alert and glossary entry (AVSpeechSynthesizer).
  Stock iOS often has no Filipino voice installed at all — the app checks at
  runtime, falls back to an English voice explicitly, and tells the user in
  Settings. That gap is itself a finding for the pitch.
- Tap targets ≥ 44pt, VoiceOver labels on all interactive elements.
- Language chosen in-app at first launch, each language named in itself.
