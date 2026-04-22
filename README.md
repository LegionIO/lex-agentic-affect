# lex-agentic-affect

Domain consolidation gem for emotion, affect, and motivational processing. Bundles 17 source extensions into one loadable unit under `Legion::Extensions::Agentic::Affect`.

## Overview

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

## Actors

| Actor | Interval | What It Does |
|-------|----------|--------------|
| `Emotion::Actors::MomentumDecay` | Every 60s | Decays emotional momentum |
| `Empathy::Actor::DecayModels` | Every 300s | Decays stale mental models in empathy store |
| `Fatigue::Actor::UpdateFatigue` | Every 60s | Advances fatigue accumulation and recovery |
| `Flow::Actor::UpdateFlow` | Every 30s | Updates flow state detection |
| `Interoception::Actors::Decay` | interval | Decays interoceptive body state signals |
| `Mood::Actor::UpdateMood` | Every 60s | Updates mood baseline |
| `Reappraisal::Actors::AutoRegulate` | Every 300s | Processes pending emotional events |
| `Regulation::Actor::RegulateEmotion` | Every 60s | Runs skill decay maintenance (background only — not live regulation) |
| `Resilience::Actor::UpdateResilience` | Every 120s | Updates resilience and recovery metrics |
| `SomaticMarker::Actors::Decay` | interval | Decays somatic marker strength |

## Installation

```ruby
gem 'lex-agentic-affect'
```

## Usage

```ruby
require 'legion/extensions/agentic/affect'

# Signal a drive
motivation = Legion::Extensions::Agentic::Affect::Motivation::Client.new
motivation.signal_drive(drive: :novelty, signal: 0.8)
motivation.commit_to_goal(goal_id: 'explore_codebase', drives: [:novelty, :competence])

# Check motivation state
motivation.drive_status
# => { drives: { novelty: { level: 0.8, satisfied: false }, ... }, mode: :motivated, overall: 0.65 }
```

## Notes

- `Affect::Motivation` reads an optional `:extinction` key from `tick_results` (from `lex-agentic-defense`) to update the survival drive. This dependency is guarded with `defined?()` and the gem works without it.
- `Regulation::Actor::RegulateEmotion` calls `update_emotional_regulation` (skill decay), not `regulate_emotion` which requires a live emotion signal and cannot be safely called as a background tick.

## Development

```bash
bundle install
bundle exec rspec        # 1562 examples, 0 failures
bundle exec rubocop      # 0 offenses
```

## License

MIT
