# Performance

Salem.exe is designed to stay open during work sessions, so the MVP avoids constant polling where practical.

## Timer-Based Work

The following systems use timers:

- FSM state transitions
- stat decay
- Cozy Points accrual
- random event rolls
- debounced save writes
- Pomodoro phases

## Lightweight Processing

The small visual layer also uses `_process()` for lightweight motion:

- `SalemView` for blink timing and a subtle state-aware bob.
- `RandomEventManager` for event cooldown accumulation.
- `WindowChrome` for the slow ambient glow and awake indicator.
- `InteractiveObject` for short hover transitions.

These loops only update a handful of values in a 420×260 canvas. If profiling
later shows idle CPU cost, decorative motion can be throttled and cooldowns can
move to timestamp comparisons during timer rolls. Disabling animations already
stops the chrome and Salem motion loops.

## Rendering

Salem uses small 64x64 PNG sprites through `AnimatedSprite2D` when the sprite collection is present. The placeholder primitive drawing remains as a fallback for missing assets.
