# Salem Sprites

The current runtime loads 64x64 transparent PNG frames from:

```text
assets/pets/salem/sprites/salem_sprite_collection_v1/salem_sprite_collection_v1/
```

## Runtime Animations

- `idle`: 5 frames
- `walk`: 6 frames
- `sit`: 4 frames
- `sleep`: 5 frames
- `eat`: 5 frames
- `play`: 6 frames
- `stretch`: 4 frames
- `curious`: 4 frames
- `judge`: 10 frames

`judge` is Salem filing his claws while judging a red test result. It currently plays on `tests_failed` and on the `code_review_judgement` random event.

## Additional Sprite Packs Checked

- `salem_16_sprites_64x64.zip`: compact 16-pose reference pack.
- `salem_sprites_individuais.zip`: six larger standalone reference sprites.
- `salem_sprite_collection_v1.zip`: complete organized 64x64 collection, used as the runtime source.
- `salem_sarcastic_nail_file_10f.zip`: ten-frame nail filing sequence, integrated into the `judge` animation.

## Naming

Keep new runtime frames in one folder per animation. File names should sort in playback order:

```text
judge/01_judgement_stare.png
judge/02_raise_paw.png
...
```
