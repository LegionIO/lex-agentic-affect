# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Mood
          module Runners
            module Mood
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex)

              def update_mood(tick_results: {}, **)
                inputs = extract_mood_inputs(tick_results)
                mood_state.update(inputs)

                Legion::Logging.debug "[mood] #{mood_state.current_mood} (v=#{mood_state.valence.round(2)} " \
                                      "a=#{mood_state.arousal.round(2)} e=#{mood_state.energy.round(2)})"

                {
                  mood:        mood_state.current_mood,
                  valence:     mood_state.valence,
                  arousal:     mood_state.arousal,
                  energy:      mood_state.energy,
                  stability:   mood_state.stability,
                  modulations: mood_state.modulations
                }
              end

              def current_mood(**)
                Legion::Logging.debug "[mood] query: #{mood_state.current_mood}"
                mood_state.to_h
              end

              def mood_modulation(parameter:, **)
                mods = mood_state.modulations
                value = mods[parameter.to_sym]

                Legion::Logging.debug "[mood] modulation: #{parameter}=#{value} (mood=#{mood_state.current_mood})"

                {
                  parameter:    parameter.to_sym,
                  modulation:   value || 0.0,
                  current_mood: mood_state.current_mood
                }
              end

              def mood_history(limit: 20, **)
                history = mood_state.history.last(limit)
                {
                  entries: history.map { |h| { mood: h[:mood], valence: h[:valence], arousal: h[:arousal], at: h[:at] } },
                  trend:   mood_state.mood_trend(window: limit),
                  count:   history.size
                }
              end

              def mood_stats(**)
                history = mood_state.history
                mood_counts = Hash.new(0)
                history.each { |h| mood_counts[h[:mood]] += 1 }

                dominant = mood_counts.max_by { |_, v| v }&.first

                {
                  current_mood:      mood_state.current_mood,
                  stability:         mood_state.stability,
                  duration:          mood_state.duration_in_current_mood,
                  trend:             mood_state.mood_trend,
                  dominant_mood:     dominant,
                  mood_distribution: mood_counts,
                  ticks_processed:   mood_state.tick_counter
                }
              end

              private

              def mood_state
                @mood_state ||= Helpers::MoodState.new
              end

              def extract_mood_inputs(tick_results)
                inputs = {}

                emotion = tick_results[:emotional_evaluation]
                if emotion.is_a?(Hash)
                  inputs[:valence] = normalize_emotional_valence(emotion)
                  inputs[:arousal] = emotion[:arousal] || emotion[:magnitude] || 0.3
                end

                inputs[:energy] = extract_energy(tick_results)

                inputs
              end

              def normalize_emotional_valence(emotion)
                if emotion[:valence].is_a?(Hash)
                  dims = emotion[:valence]
                  positive = (dims[:importance] || 0) + (dims[:familiarity] || 0)
                  negative = (dims[:urgency] || 0) + (dims[:novelty] || 0)
                  ((positive - negative + 1.0) / 2.0).clamp(0.0, 1.0)
                elsif emotion[:magnitude].is_a?(Numeric)
                  (emotion[:magnitude] + 0.5).clamp(0.0, 1.0)
                else
                  0.5
                end
              end

              def extract_energy(tick_results)
                load = tick_results[:elapsed]
                budget = tick_results[:budget]
                return 0.5 unless load.is_a?(Numeric) && budget.is_a?(Numeric) && budget.positive?

                utilization = load / budget
                (1.0 - utilization).clamp(0.0, 1.0)
              end
            end
          end
        end
      end
    end
  end
end
