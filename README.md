# Salem.exe

A tiny developer companion living on your desktop.

Salem.exe is a cozy 2D desktop companion built with Godot. The MVP focuses on a small virtual cat named Salem who sits above your desktop, moves around, reacts to simple interactions, earns Cozy Points slowly, and exposes clean extension points for future developer integrations.

## MVP Features

- Borderless transparent desktop window configured for always-on-top mode.
- Draggable pet with saved position.
- Configurable finite state machine with `idle`, `walk`, `sit`, `sleep`, `eat`, `play`, `stretch`, and `curious`.
- Non-punitive needs: energy, hunger, affection, and mood.
- Personality profile that changes behaviour weights.
- Cozy Points progression.
- Initial interactive objects: Cardboard Box, Laptop, and Cat Bed.
- Random event system with functional `zoomies`, `stare_into_void`, and `random_sleep` events.
- Day-period service for morning, afternoon, evening, night, and late night.
- Mock developer activity provider for commit, tests passed, tests failed, and break events.
- Optional Pomodoro timer that can request breaks.
- Placeholder audio service with cue names ready for royalty-free assets.
- Local JSON persistence with save versioning and safe fallbacks.
- Settings menu and debug panel for development builds.

## Placeholder Screenshot

The current MVP uses generated placeholder shapes drawn in Godot. Final sprites can be added later under:

```text
assets/pets/salem/sprites/
```

## Requirements

- Godot Engine 4.2 or newer.
- Windows is the initial target platform.

## How to Run

Open this folder in Godot and run the main scene:

```text
res://scenes/main.tscn
```

The configured entrypoint is already set in `project.godot`.

## How to Test

With Godot available in your PATH:

```text
godot --headless --path . --script res://tests/domain_cli_test.gd
```

## Controls

- Left-drag Salem to move him.
- Right-click anywhere in the window to open the interaction menu.
- Use the debug panel in debug builds to force moods, states, events, and developer reactions.

## Architecture

```text
src/
  core/          global orchestration, logging, save, settings, time
  pet/           Salem controller, FSM, stats, mood, personality, view
  progression/   Cozy Points and object unlocks
  objects/       interactive desktop objects
  events/        random event definitions and manager
  integrations/  developer, system activity, and Pomodoro abstractions
  audio/         placeholder cue service for future sound assets
  platform/      desktop window abstraction
  ui/            interaction menu, settings, debug, HUD
```

Domain decisions are kept outside the UI where practical. State selection, stat decay, mood calculation, event cooldowns, and progression are isolated so they can be tested or tuned without rewriting scenes.

## Current Limitations

- Art and animation are placeholders.
- Selective mouse passthrough is wrapped in `DesktopWindowManager`, but platform behaviour must be validated on the final target machine.
- Developer integrations are mock-only. The MVP does not read repositories, IDE data, or user files.
- Audio architecture is planned but no sound assets are included yet.
- Automated Godot test tooling is not configured yet.

## Roadmap

- v0.1: Desktop overlay, pet FSM, placeholder animation, interaction, save.
- v0.2: Deeper mood/personality balancing, object-specific actions, Cozy Points unlock flow.
- v0.3: Sound, richer settings, stronger day/night presentation.
- v0.4: Opt-in Git and editor integrations, Pomodoro polish, developer reactions.
- v0.5: Multiple pets, customization, themes, sprite packs.
- v1.0: Release packaging, achievements, cloud save, workshop-style custom pets.

## Privacy

The MVP does not collect data, send telemetry, call external services, or inspect arbitrary files. Future developer integrations should remain opt-in.

## Contributing

Keep changes small, readable, and aligned with the existing structure. Prefer configurable resources and focused services over large nodes with mixed responsibilities.

## License

License not selected yet. Add one before public distribution.
