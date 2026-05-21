# OnePanel MVP Prototype

## Prototype Purpose

This prototype document captures the visual and interaction baseline before implementation begins. It translates the approved PRD into a concrete macOS window model so development decisions stay consistent.

## Source Inputs

- Product requirements in [PRD.md](/Volumes/D/xbc/iOSProjects/OnePanel/PRD.md)
- User-provided visual reference showing:
- A menu bar entry
- A single floating note panel
- A pin action for top-most mode
- A lightweight settings surface

## Visual Direction

- Tone: light, quiet, native, low-interruption
- Layout: single-pane composition with no sidebar and no record list
- Editing model: full-surface freeform text editing
- Controls: only the minimum chrome needed for window control

## Window Prototype

### Main Panel

- A single resizable floating window
- Title bar with:
- App title `OnePanel`
- Pin / unpin button on the top-right
- Settings entry on the top-right
- Main content region:
- Large plain text editor
- No cards
- No folders
- No per-record operations

### Settings Surface

- Lightweight settings window
- Includes only:
- Global hotkey
- Remember window state
- Default window behavior

## Interaction Prototype

### Show / Hide

- Triggered by menu bar icon or global hotkey
- Re-trigger toggles visibility

### Focus Behavior

- When the panel is focused, `ESC` hides it immediately

### Pinning

- Unpinned:
- Floating window that can be covered by other windows
- Pinned:
- Always-on-top window that remains visible above normal app windows

### Cross-Space Behavior

- If invoked from any desktop, the panel appears in the current desktop
- After it appears, switching desktops keeps the panel visible

## Size Guidance

- Small: quick lookup
- Medium: default daily use
- Large: long-form notes or extended command reference

The implementation must allow free resizing instead of locking to preset dimensions.

## Implementation Notes

- Prefer native macOS visual behaviors over highly customized chrome
- Preserve a lightweight utility feel rather than a document-editor feel
- Native windowing behavior should only be overridden where required by the PRD:
- Cross-space visibility
- Pin / unpin top-most behavior
- Global hotkey toggling
