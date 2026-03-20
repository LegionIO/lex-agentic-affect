# lex-agentic-affect

Domain consolidation gem for emotion, affect, and motivational processing. Bundles 17 source extensions into one loadable unit under `Legion::Extensions::Agentic::Affect`.

## Overview

**Gem**: `lex-agentic-affect`
**Version**: 0.1.1
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

- `Affect::Emotion::Actors::MomentumDecay` — runs every 60s, decays emotional momentum via `decay_momentum`
- `Affect::Interoception::Actors::Decay` — interval actor, decays interoceptive body state signals
- `Affect::Reappraisal::Actors::AutoRegulate` — runs every 300s, processes pending emotional events
- `Affect::SomaticMarker::Actors::Decay` — interval actor, decays somatic marker strength

## Installation

```ruby
gem 'lex-agentic-affect'
```

## Development

```bash
bundle install
bundle exec rspec        # 1523 examples, 0 failures
bundle exec rubocop      # 0 offenses
```

## License

MIT
