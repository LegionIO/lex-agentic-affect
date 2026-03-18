# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Mood
          module Helpers
            class MoodState
              attr_reader :current_mood, :valence, :arousal, :energy, :stability, :history, :tick_counter

              def initialize
                @valence = 0.5
                @arousal = 0.3
                @energy = 0.5
                @stability = 0.8
                @current_mood = :neutral
                @history = []
                @tick_counter = 0
              end

              def update(inputs)
                @tick_counter += 1
                return @current_mood unless (@tick_counter % Constants::UPDATE_INTERVAL).zero?

                alpha = effective_alpha
                @valence = ema(@valence, inputs[:valence] || @valence, alpha)
                @arousal = ema(@arousal, inputs[:arousal] || @arousal, alpha)
                @energy = ema(@energy, inputs[:energy] || @energy, alpha)

                compute_stability
                classify_mood
                record_history

                @current_mood
              end

              def modulations
                Constants::MOOD_MODULATIONS.fetch(@current_mood, Constants::MOOD_MODULATIONS[:neutral])
              end

              def inertia
                Constants::MOOD_INERTIA.fetch(@current_mood, 0.5)
              end

              def duration_in_current_mood
                return 0 if @history.empty?

                consecutive = 0
                @history.reverse_each do |entry|
                  break unless entry[:mood] == @current_mood

                  consecutive += 1
                end
                consecutive * Constants::UPDATE_INTERVAL
              end

              def mood_trend(window: 20)
                recent = @history.last(window)
                return :insufficient_data if recent.size < 3

                valences = recent.map { |h| h[:valence] }
                avg_first = valences[0...(valences.size / 2)].sum / (valences.size / 2).to_f
                avg_second = valences[(valences.size / 2)..].sum / (valences.size - (valences.size / 2)).to_f

                delta = avg_second - avg_first
                if delta > 0.05
                  :improving
                elsif delta < -0.05
                  :declining
                else
                  :stable
                end
              end

              def to_h
                {
                  current_mood: @current_mood,
                  valence:      @valence.round(3),
                  arousal:      @arousal.round(3),
                  energy:       @energy.round(3),
                  stability:    @stability.round(3),
                  modulations:  modulations,
                  inertia:      inertia,
                  duration:     duration_in_current_mood,
                  trend:        mood_trend,
                  history_size: @history.size
                }
              end

              private

              def effective_alpha
                base_alpha = Constants::MOOD_ALPHA
                current_inertia = inertia
                base_alpha * (1.0 - (current_inertia * 0.5))
              end

              def ema(current, observed, alpha)
                ((current * (1.0 - alpha)) + (observed * alpha)).clamp(0.0, 1.0)
              end

              def compute_stability
                return if @history.size < 3

                recent_moods = @history.last(10).map { |h| h[:mood] }
                unique_moods = recent_moods.uniq.size
                @stability = (1.0 - (unique_moods.to_f / [recent_moods.size, 1].max)).clamp(0.0, 1.0)
              end

              def classify_mood
                best_match = :neutral
                best_score = 0

                Constants::MOOD_CLASSIFICATION.each do |mood, criteria|
                  score = match_score(criteria)
                  if score > best_score
                    best_score = score
                    best_match = mood
                  end
                end

                @current_mood = best_match
              end

              def match_score(criteria)
                matched = 0
                total = criteria.size

                matched += 1 if criteria[:valence]&.cover?(@valence)
                matched += 1 if criteria[:arousal]&.cover?(@arousal)
                matched += 1 if criteria[:energy]&.cover?(@energy)

                matched.to_f / [total, 1].max
              end

              def record_history
                @history << {
                  mood:      @current_mood,
                  valence:   @valence,
                  arousal:   @arousal,
                  energy:    @energy,
                  stability: @stability,
                  at:        Time.now.utc
                }
                @history = @history.last(Constants::MAX_MOOD_HISTORY)
              end
            end
          end
        end
      end
    end
  end
end
