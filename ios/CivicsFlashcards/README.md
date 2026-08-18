# Civics 128 — native iOS app

SwiftUI flashcards for the 2025 USCIS naturalization civics test (128 questions).
Swipe between cards, tap to flip, mark cards known/for-review (saved on device),
filter by section, verify any answer at the official USCIS source, and an
optional donation link.

No dependencies. Works fully offline. Minimum iOS 16.

## Files

```
CivicsFlashcards/
  CivicsFlashcardsApp.swift   app entry point
  ContentView.swift           main screen: card, swipe gesture, controls, filters
  CardView.swift              flip card (front = question, back = answers + source link)
  AboutView.swift             about sheet: sources, donation link, disclaimers
  DeckViewModel.swift         deck state, filters, progress persistence (UserDefaults)
  Models.swift                Card model + JSON loading
  Config.swift                donation URL + source URLs  ← EDIT THIS
  civics128.json              all 128 questions/answers (generated from the web deck)
```

## Build it on your Mac (10 minutes)

1. Open Xcode → **File → New → Project… → iOS → App**.
   - Product Name: `CivicsFlashcards`
   - Interface: **SwiftUI**, Language: **Swift**
   - Organization Identifier: e.g. `com.alexzakv` (bundle id becomes `com.alexzakv.CivicsFlashcards`)
   - Uncheck tests if you like.
2. In Finder, open this folder's `CivicsFlashcards/` subfolder. Delete Xcode's
   generated `ContentView.swift` and `CivicsFlashcardsApp.swift`, then drag **all
   8 files** from this folder into the Xcode project navigator (into the
   `CivicsFlashcards` group). In the dialog: check **"Copy items if needed"** and
   make sure the **CivicsFlashcards target is checked** — especially for
   `civics128.json` (if the JSON isn't in the target, the app builds but shows an
   empty deck).
3. **Edit `Config.swift`** — replace the `CHANGE-ME` donation URL with your real
   page (Buy Me a Coffee / GitHub Sponsors / PayPal.me / Ko-fi), or set it to
   `nil` to hide the link.
4. Select your device or a simulator → **Run** (⌘R).
5. Signing: project → target → *Signing & Capabilities* → pick your Apple
   developer team. Xcode handles the rest automatically.

## Ship it

**TestFlight (recommended first step)**
1. Product → **Archive** → *Distribute App* → **App Store Connect** → Upload.
2. In [App Store Connect](https://appstoreconnect.apple.com): create the app
   (name, bundle id), then under TestFlight invite testers by email or share a
   public TestFlight link. Internal testers need no review; external links get a
   light review (~1 day).

**App Store**
1. Same archive/upload. In App Store Connect fill in the listing and submit.
2. Suggested metadata:
   - **Name:** Civics 128 (do **not** use "USCIS" in the name — implies
     government affiliation, guideline 5.2.5)
   - **Category:** Education
   - **Price:** Free
   - **Privacy — "Data Collection":** answer **"Data Not Collected"** (true: all
     progress is on-device, no analytics, no accounts).
   - **Age rating:** 4+
   - **Description tip:** state clearly it's an independent study aid based on
     the official public-domain USCIS questions, works offline, and applies to
     N-400 applications filed on or after Oct 20, 2025.
3. Screenshots: run in the iPhone 15 Pro Max and iPhone SE simulators, take
   screenshots of the question card, the answer card, and the section filter.

## App Review notes (read before submitting)

- **Donation link:** it opens in the browser (never an in-app purchase flow),
  which is the compliant pattern. If a reviewer still objects (it happens with
  personal tip links), set `AppConfig.donationURL = nil`, rebuild, resubmit —
  the app is otherwise unaffected. The alternative is an in-app "tip jar" via
  StoreKit, which Apple always accepts (they keep 15%).
- **Not a repackaged website:** if asked, note the app is fully native SwiftUI,
  offline, with on-device progress — no web content except outbound links to
  the official government source.
- **Content rights:** USCIS civics questions are U.S. government work
  (public domain). The About screen carries a non-affiliation disclaimer.

## Updating the questions

The deck lives in `civics128.json`, generated from the web version
(`docs/index.html` in this repo) so all copies stay identical. After the deck
changes, regenerate with the repo script (ask Claude, or see the git history
for `ios/`), replace the JSON in Xcode, bump the build number, and re-upload.
Remember: answers to questions 24, 30, 38, 39, 53, 57 change with elections —
plan an app update after each change, and the in-app source links cover users
on old versions in the meantime.
