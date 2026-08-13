# Architecture

Salem.exe is structured around small Godot nodes and resources with clear responsibilities.

## Main Composition

`GameManager` creates and connects the runtime services:

- `DesktopWindowManager` configures the native overlay window.
- `PetController` owns Salem's visual node, stats, and state machine.
- `CozyPoints` and `UnlockManager` handle progression.
- `ObjectManager` creates unlocked interactive objects.
- `RandomEventManager` owns random event probability and cooldown checks.
- `MockDeveloperActivityProvider` exposes development events.
- `PomodoroTimer` emits break recommendations when enabled.
- `AudioService` centralizes sound cue requests while MVP assets are still placeholders.
- UI nodes remain thin and emit user intent.

## Dependency Direction

UI talks to controllers through signals. Controllers emit global events where cross-cutting reactions are useful. Domain calculations live in resources or dedicated services instead of being embedded in menu code.

## Event Bus

`EventBus` is used only for broad app events:

- pet state and mood changes
- Cozy Points changes
- developer events
- random events
- settings changes
- notifications

Local node-to-node interactions still use direct signals when the relationship is clear.

## Configuration

Behaviour weights, mood modifiers, state durations, stat tick interval, and Cozy Points gain live in `PetBehaviourConfig`. This keeps balancing changes away from orchestration code.

## Performance Notes

The MVP uses timers for stat decay, state transitions, progression, saves, and random event rolls. `_process()` is limited to lightweight visual blinking and random event cooldown accumulation.
