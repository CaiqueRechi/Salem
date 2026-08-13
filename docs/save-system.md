# Save System

The MVP saves to:

```text
user://save.json
```

Saved data includes:

- save version
- window position
- pet position
- Cozy Points
- energy
- hunger
- affection
- mood
- personality
- unlocked objects
- settings
- last session timestamp

## Safety

`SaveManager` validates the loaded JSON shape and falls back to defaults on invalid data. Newer save versions are not loaded by older builds.

## Debouncing

Frequent changes queue a short delayed save instead of writing immediately on every signal.
