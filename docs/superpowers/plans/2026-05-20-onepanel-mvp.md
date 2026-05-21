# OnePanel MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first working local-only macOS version of OnePanel with a menu bar entry, a single editable panel, pin/unpin behavior, ESC hide, remembered window state, and a configurable global hotkey.

**Architecture:** Use a Swift package as the initial project container so the repo can start from an empty directory without external scaffolding. Keep business logic and persistence in testable plain Swift types, and bridge into AppKit / SwiftUI only at the app shell and window-control layers.

**Tech Stack:** Swift 6, SwiftUI, AppKit, Swift Testing, local file persistence, package-based build/test flow

---

## Step2 Task Breakdown

### Phase A: Foundation

- Initialize a new Swift package for the macOS app codebase
- Define the module layout for app shell, persistence, settings, hotkey integration, and window control
- Add a minimal packaging script for generating a local `.app` bundle later if needed

### Phase B: Testable Core

- Implement a document store for the single text document
- Implement settings persistence for hotkey and remembered window state
- Implement a window-state model for size, position, and pin state

### Phase C: App Shell

- Add the menu bar app entry point
- Add the single editor panel
- Add a lightweight settings window

### Phase D: Desktop Behaviors

- Add show / hide toggling
- Add pin / unpin top-most switching
- Add cross-space visibility behavior
- Add `ESC` hide behavior
- Add remembered window frame restore

### Phase E: Validation

- Run unit tests
- Run package build
- Launch the app locally and verify core flows manually

## Step3 Prototype Baseline

- Use the single-panel utility layout defined in [2026-05-20-onepanel-mvp-prototype.md](/Volumes/D/xbc/iOSProjects/OnePanel/docs/prototypes/2026-05-20-onepanel-mvp-prototype.md)
- Keep the visual language native and minimal
- Do not add sidebar, list, markdown rendering, or multi-document features

## File Structure

- Create: `Package.swift`
- Create: `Sources/OnePanelApp/OnePanelApp.swift`
- Create: `Sources/OnePanelApp/AppDelegate.swift`
- Create: `Sources/OnePanelApp/AppModel.swift`
- Create: `Sources/OnePanelApp/Models/WindowFrameState.swift`
- Create: `Sources/OnePanelApp/Services/DocumentStore.swift`
- Create: `Sources/OnePanelApp/Services/SettingsStore.swift`
- Create: `Sources/OnePanelApp/Services/HotkeyManager.swift`
- Create: `Sources/OnePanelApp/Services/PanelWindowController.swift`
- Create: `Sources/OnePanelApp/Views/PanelRootView.swift`
- Create: `Sources/OnePanelApp/Views/PlainTextEditorView.swift`
- Create: `Sources/OnePanelApp/Views/SettingsView.swift`
- Create: `Sources/OnePanelApp/Support/AppPaths.swift`
- Create: `Tests/OnePanelAppTests/DocumentStoreTests.swift`
- Create: `Tests/OnePanelAppTests/SettingsStoreTests.swift`
- Create: `Tests/OnePanelAppTests/WindowFrameStateTests.swift`

### Task 1: Initialize the Package

**Files:**
- Create: `Package.swift`
- Create: `Sources/OnePanelApp/`
- Create: `Tests/OnePanelAppTests/`

- [ ] **Step 1: Initialize the package**

Run: `swift package init --type executable --enable-swift-testing --name OnePanel`
Expected: package manifest plus starter sources and tests are created

- [ ] **Step 2: Replace the starter layout with app-specific folders**

Create folders for:

```text
Sources/OnePanelApp/Models
Sources/OnePanelApp/Services
Sources/OnePanelApp/Views
Sources/OnePanelApp/Support
Tests/OnePanelAppTests
```

- [ ] **Step 3: Update the manifest for macOS app dependencies**

`Package.swift` should:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OnePanel",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "OnePanel", targets: ["OnePanelApp"])
    ],
    targets: [
        .executableTarget(
            name: "OnePanelApp"
        ),
        .testTarget(
            name: "OnePanelAppTests",
            dependencies: ["OnePanelApp"]
        )
    ]
)
```

### Task 2: Build the Persistence Core with TDD

**Files:**
- Create: `Sources/OnePanelApp/Models/WindowFrameState.swift`
- Create: `Sources/OnePanelApp/Services/DocumentStore.swift`
- Create: `Sources/OnePanelApp/Services/SettingsStore.swift`
- Test: `Tests/OnePanelAppTests/DocumentStoreTests.swift`
- Test: `Tests/OnePanelAppTests/SettingsStoreTests.swift`
- Test: `Tests/OnePanelAppTests/WindowFrameStateTests.swift`

- [ ] **Step 1: Write the failing document persistence tests**
- [ ] **Step 2: Run `swift test` and confirm the new tests fail for missing types**
- [ ] **Step 3: Implement the minimal `DocumentStore` and `WindowFrameState`**
- [ ] **Step 4: Write the failing settings persistence tests**
- [ ] **Step 5: Run `swift test` and confirm the settings tests fail correctly**
- [ ] **Step 6: Implement the minimal `SettingsStore`**
- [ ] **Step 7: Run `swift test` and confirm the persistence tests pass**

### Task 3: Build the App Shell

**Files:**
- Create: `Sources/OnePanelApp/OnePanelApp.swift`
- Create: `Sources/OnePanelApp/AppDelegate.swift`
- Create: `Sources/OnePanelApp/AppModel.swift`
- Create: `Sources/OnePanelApp/Views/PanelRootView.swift`
- Create: `Sources/OnePanelApp/Views/PlainTextEditorView.swift`
- Create: `Sources/OnePanelApp/Views/SettingsView.swift`

- [ ] **Step 1: Write a failing smoke test for default app model state where practical**
- [ ] **Step 2: Implement the observable app model for panel text, pin state, and window visibility**
- [ ] **Step 3: Implement the SwiftUI text editor surface**
- [ ] **Step 4: Implement the settings view for hotkey and remembered window state**
- [ ] **Step 5: Run `swift test` and keep the core tests green**

### Task 4: Add Window Control and Menu Bar Behavior

**Files:**
- Create: `Sources/OnePanelApp/Services/PanelWindowController.swift`
- Create: `Sources/OnePanelApp/Services/HotkeyManager.swift`
- Modify: `Sources/OnePanelApp/AppDelegate.swift`
- Modify: `Sources/OnePanelApp/OnePanelApp.swift`

- [ ] **Step 1: Add a panel controller that can show, hide, restore frame, and toggle pin state**
- [ ] **Step 2: Configure cross-space behavior and always-on-top behavior in AppKit**
- [ ] **Step 3: Add the menu bar status item and wire it to panel toggling**
- [ ] **Step 4: Add the global hotkey manager and wire it to the same toggle action**
- [ ] **Step 5: Add `ESC` handling in the panel so focused panels hide immediately**
- [ ] **Step 6: Run `swift test` and `swift build`**

### Task 5: Verify the MVP End-to-End

**Files:**
- Modify as needed after verification feedback

- [ ] **Step 1: Launch the app locally**
- [ ] **Step 2: Verify menu bar toggle**
- [ ] **Step 3: Verify global hotkey toggle**
- [ ] **Step 4: Verify pin / unpin behavior**
- [ ] **Step 5: Verify window size and position restore**
- [ ] **Step 6: Verify text auto-save and reload**
- [ ] **Step 7: Verify `ESC` hide**
- [ ] **Step 8: Run final verification commands**

Run:

```bash
swift test
swift build
```

Expected:

```text
All tests pass
Build completes successfully
```

## Self-Review Notes

- Spec coverage: covered menu bar entry, single plain-text panel, local persistence, hotkey, pinning, cross-space visibility, ESC hide, remembered window state, and settings
- Known gap by design: step 6 of the external vibe flow, automatic self-debugging, is intentionally deferred per user instruction
