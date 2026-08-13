# Desktop Window

The MVP configures the app as a small desktop overlay:

- borderless
- transparent background
- always on top
- fixed small size
- draggable pet
- saved window and pet position

The implementation lives in `DesktopWindowManager`.

## Mouse Passthrough

Godot exposes mouse passthrough polygon support on native windows, but selective behaviour can vary by OS, renderer, and platform backend. The MVP wraps this behind:

```text
DesktopWindowManager.set_mouse_passthrough()
DesktopWindowManager.set_interactive_region()
```

Fallback behaviour is a normal interactive transparent window. This keeps the pet usable even when selective passthrough cannot be trusted.

## Platform Strategy

Windows is the initial platform. OS-specific logic should stay behind `src/platform/` so future native extensions or per-platform implementations can replace the current Godot-only version.
