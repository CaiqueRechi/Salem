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

Only two MVP scripts use `_process()`:

- `SalemView` for blink timing.
- `RandomEventManager` for event cooldown accumulation.

Both are intentionally tiny. If profiling later shows idle CPU cost, cooldowns can move to timestamp comparisons during timer rolls.

## Rendering

Salem uses small 64x64 PNG sprites through `AnimatedSprite2D` when the sprite collection is present. The placeholder primitive drawing remains as a fallback for missing assets.
