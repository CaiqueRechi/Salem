# Audio

The MVP includes an `AudioService` so gameplay code can request sound cues without depending on concrete assets.

Known cues:

```text
meow
purr
sleep
interaction
notification
```

No copyrighted audio is included. Future sounds should be royalty-free or original and routed through `AudioService.play_cue()`.

The service respects the `sounds_enabled` setting.
