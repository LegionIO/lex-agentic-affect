# lex-agentic-affect

**Parent**: `../CLAUDE.md`

## What Is This Gem?

Domain consolidation gem for emotion, affect, and motivational processing. Bundles 17 source extensions into one loadable unit under `Legion::Extensions::Agentic::Affect`.

**Gem**: `lex-agentic-affect`
**Version**: 0.1.12
**Namespace**: `Legion::Extensions::Agentic::Affect`

## Sub-Modules

| Sub-Module | Source Gem | Purpose |
|---|---|---|
| `Affect::Emotion` | `lex-emotion` | Four-dimensional emotional valence/arousal, EMA momentum, gut instinct |
| `Affect::Mood` | `lex-mood` | Background mood baseline distinct from discrete emotions |
| `Affect::Appraisal` | `lex-appraisal` | Lazarus appraisal theory — primary/secondary appraisal of events |
| `Affect::CognitiveEmpathy` | `lex-cognitive-empathy` | Cognitive empathy processing |
| `Affect::Empathy` | `lex-empathy` | Affective and cognitive empathy |
| `Affect::Reappraisal` | `lex-cognitive-reappraisal` | Gross process model — six emotion regulation strategies |
| `Affect::Regulation` | `lex-emotional-regulation` | Regulation strategy selection and effectiveness tracking |
| `Affect::Defusion` | `lex-cognitive-defusion` | ACT-style cognitive defusion from difficult thoughts |
| `Affect::Contagion` | `lex-cognitive-contagion` | Emotional contagion spread across agent interactions |
| `Affect::SomaticMarker` | `lex-somatic-marker` | Damasio somatic marker hypothesis — gut-feeling tagging |
| `Affect::Interoception` | `lex-interoception` | Internal body state signals (fatigue, tension, arousal) |
| `Affect::Flow` | `lex-flow` | Csikszentmihalyi flow state |
| `Affect::Fatigue` | `lex-fatigue` | Mental fatigue accumulation and recovery modeling |
| `Affect::Motivation` | `lex-motivation` | Drive states — homeostatic and intrinsic motivation |
| `Affect::Reward` | `lex-reward` | Reward signal computation and prediction error |
| `Affect::Resilience` | `lex-resilience` | Recovery capacity and stress inoculation |
| `Affect::Resonance` | `lex-cognitive-resonance` | Affective resonance patterns |

## Key Runner Methods

### `Motivation::Runners::Motivation`

| Method | Key Args | Returns |
|--------|----------|---------|
| `update_motivation` | `tick_results: {}` | `{ mode:, overall_level:, intrinsic_average:, extrinsic_average:, amotivated:, burnout: }` |
| `signal_drive` | `drive:, signal:` | `{ success:, drive:, level: }` |
| `commit_to_goal` | `goal_id:, drives:` | `{ success:, goal_id:, energy: }` |
| `release_goal` | `goal_id:` | `{ success:, goal_id: }` |
| `motivation_for` | `goal_id:` | `{ goal_id:, energy: }` |
| `most_motivated_goal` | — | `{ goal_id:, energy:, drives: }` |
| `drive_status` | — | `{ drives:, mode:, overall: }` |
| `motivation_stats` | — | full stats hash |

`update_motivation` reads from `tick_results`: `:consent` (autonomy), `:prediction_engine` (competence), `:trust` (relatedness), `:memory_retrieval` (novelty), `:scheduler` (obligation), `:extinction` (survival — optional dep on lex-agentic-defense).

## Actors

| Actor | Interval | Target Method |
|-------|----------|---------------|
| `Emotion::Actors::MomentumDecay` | Every 60s | `decay_momentum` on `Emotion::Runners::Valence` |
| `Empathy::Actor::DecayModels` | Every 300s | `decay_models` on `Empathy::Runners::Empathy` |
| `Fatigue::Actor::UpdateFatigue` | Every 60s | `update_fatigue` on `Fatigue::Runners::Fatigue` |
| `Flow::Actor::UpdateFlow` | Every 30s | `update_flow` on `Flow::Runners::Flow` |
| `Interoception::Actors::Decay` | interval | decays interoceptive body state signals |
| `Mood::Actor::UpdateMood` | Every 60s | `update_mood` on `Mood::Runners::Mood` |
| `Reappraisal::Actors::AutoRegulate` | Every 300s | `auto_regulate` — processes pending emotional events |
| `Regulation::Actor::RegulateEmotion` | Every 60s | `update_emotional_regulation` — skill decay maintenance (does NOT call `regulate_emotion` which requires live signal) |
| `Resilience::Actor::UpdateResilience` | Every 120s | `update_resilience` on `Resilience::Runners::Resilience` |
| `SomaticMarker::Actors::Decay` | interval | decays somatic marker strength |

## Integration Points

- `Motivation::Runners::Motivation#update_motivation` reads `:extinction` key from `tick_results` (optional dep on `lex-agentic-defense` Extinction runner); survival drive is updated when `tick_results.dig(:extinction, :level)` is present.
- `Affect::Emotion` maps to the `emotional_evaluation` tick phase.
- `Affect::Fatigue` is distinct from `Homeostasis::FatigueModel` — this models affect-layer fatigue (mental exhaustion, burnout), while the homeostasis version models cognitive resource curves.

## Dependencies

**Runtime** (from gemspec):
- `legion-cache` >= 1.3.11
- `legion-crypt` >= 1.4.9
- `legion-data` >= 1.4.17
- `legion-json` >= 1.2.1
- `legion-logging` >= 1.3.2
- `legion-settings` >= 1.3.14
- `legion-transport` >= 1.3.9

**Optional at runtime** (guarded with `defined?`):
- `lex-agentic-defense` Extinction subsystem — for survival drive in `Motivation`

## Development

```bash
bundle install
bundle exec rspec        # 1562 examples, 0 failures
bundle exec rubocop      # 0 offenses
```
