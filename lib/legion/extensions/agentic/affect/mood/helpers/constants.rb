# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Mood
          module Helpers
            module Constants
              # Mood states (valence x arousal quadrants + neutral)
              MOOD_STATES = %i[
                serene
                content
                curious
                energized
                anxious
                frustrated
                melancholic
                flat
                neutral
              ].freeze

              # Mood dimensions
              DIMENSIONS = %i[valence arousal energy stability].freeze

              # EMA alpha for mood updates (slow — mood is resistant to change)
              MOOD_ALPHA = 0.1

              # How many ticks before mood recalculates
              UPDATE_INTERVAL = 5

              # Mood history capacity
              MAX_MOOD_HISTORY = 200

              # Dimension ranges for mood classification
              MOOD_CLASSIFICATION = {
                serene:      { valence: (0.3..), arousal: (..0.3), energy: (0.3..) },
                content:     { valence: (0.3..), arousal: (0.3..0.6) },
                curious:     { valence: (0.1..), arousal: (0.4..0.7), energy: (0.4..) },
                energized:   { valence: (0.2..), arousal: (0.7..) },
                anxious:     { valence: (..0.3), arousal: (0.6..) },
                frustrated:  { valence: (..-0.1), arousal: (0.4..0.8) },
                melancholic: { valence: (..-0.1), arousal: (..0.4) },
                flat:        { valence: (-0.2..0.2), arousal: (..0.3), energy: (..0.3) }
              }.freeze

              # Modulation effects: how each mood biases cognitive processing
              MOOD_MODULATIONS = {
                serene:      { attention_threshold: -0.1, risk_tolerance: 0.1, curiosity_boost: 0.0 },
                content:     { attention_threshold: 0.0, risk_tolerance: 0.05, curiosity_boost: 0.05 },
                curious:     { attention_threshold: -0.15, risk_tolerance: 0.1, curiosity_boost: 0.2 },
                energized:   { attention_threshold: -0.05, risk_tolerance: 0.15, curiosity_boost: 0.1 },
                anxious:     { attention_threshold: -0.2, risk_tolerance: -0.2, curiosity_boost: -0.1 },
                frustrated:  { attention_threshold: 0.1, risk_tolerance: -0.1, curiosity_boost: -0.15 },
                melancholic: { attention_threshold: 0.15, risk_tolerance: -0.15, curiosity_boost: -0.2 },
                flat:        { attention_threshold: 0.2, risk_tolerance: 0.0, curiosity_boost: -0.1 },
                neutral:     { attention_threshold: 0.0, risk_tolerance: 0.0, curiosity_boost: 0.0 }
              }.freeze

              # Mood inertia — how resistant each mood is to change
              MOOD_INERTIA = {
                serene:      0.7,
                content:     0.6,
                curious:     0.4,
                energized:   0.3,
                anxious:     0.5,
                frustrated:  0.5,
                melancholic: 0.8,
                flat:        0.9,
                neutral:     0.2
              }.freeze
            end
          end
        end
      end
    end
  end
end
