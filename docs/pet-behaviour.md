# Pet Behaviour

Salem uses a finite state machine with the following MVP states:

```text
idle
walk
sit
sleep
eat
play
stretch
curious
```

The next state is selected by `PetBehaviourConfig.calculate_next_state()`.

Inputs considered:

- current state
- mood
- personality profile
- time period
- weighted randomness

## Needs

Needs are normalized from 0 to 100:

- energy
- hunger
- affection

These values are intentionally non-punitive. Low hunger does not harm Salem; it only makes eating more likely. Low energy makes sleep and sitting more likely.

## Moods

Moods are:

```text
happy
sleepy
playful
curious
hungry
grumpy
neutral
```

Mood calculation is centralized in `PetStats`.

## Personality

`PersonalityProfile` contains:

- playfulness
- sleepiness
- curiosity
- sociability
- chaos

Salem's defaults lean curious, playful, and a bit sleepy.
