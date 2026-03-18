# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Resilience
          module Helpers
            class ResilienceModel
              attr_reader :dimensions, :growth_bonus, :history

              def initialize
                @dimensions = Constants::DIMENSIONS.keys.to_h { |d| [d, 0.5] }
                @growth_bonus = 0.0
                @history = []
              end

              def update_from_tracker(tracker)
                update_elasticity(tracker)
                update_robustness(tracker)
                update_adaptability(tracker)
                update_growth(tracker)

                record_snapshot
              end

              def composite_score
                total = 0.0
                Constants::DIMENSIONS.each do |dim, config|
                  total += (@dimensions[dim] + (dim == :growth ? @growth_bonus : 0.0)) * config[:weight]
                end
                total.clamp(0.0, 1.0)
              end

              def classification
                score = composite_score
                if score >= Constants::ANTIFRAGILITY_THRESHOLD
                  :antifragile
                elsif score >= 0.5
                  :resilient
                elsif score >= Constants::FRAGILITY_THRESHOLD
                  :fragile
                else
                  :brittle
                end
              end

              def dimension_detail(name)
                return nil unless @dimensions.key?(name)

                {
                  name:    name,
                  value:   @dimensions[name].round(4),
                  config:  Constants::DIMENSIONS[name],
                  trend:   dimension_trend(name),
                  healthy: @dimensions[name] >= 0.5
                }
              end

              def trend
                return :insufficient_data if @history.size < 5

                recent = @history.last(10)
                scores = recent.map { |h| h[:composite] }
                first_half = scores[0...(scores.size / 2)]
                second_half = scores[(scores.size / 2)..]
                diff = mean(second_half) - mean(first_half)

                if diff > 0.03
                  :strengthening
                elsif diff < -0.03
                  :weakening
                else
                  :stable
                end
              end

              def to_h
                {
                  dimensions:   @dimensions.transform_values { |v| v.round(4) },
                  growth_bonus: @growth_bonus.round(4),
                  composite:    composite_score.round(4),
                  class:        classification,
                  trend:        trend
                }
              end

              private

              def update_elasticity(tracker)
                speed = tracker.average_recovery_speed
                signal = if speed.zero?
                           0.5
                         elsif speed <= 1.0
                           0.7 + ((1.0 - speed) * 0.3)
                         else
                           [0.3, 0.7 - ((speed - 1.0) * 0.2)].max
                         end
                @dimensions[:elasticity] = ema(@dimensions[:elasticity], signal, Constants::RESILIENCE_ALPHA)
              end

              def update_robustness(tracker)
                worst = tracker.worst_health
                @dimensions[:robustness] = ema(@dimensions[:robustness], worst, Constants::RESILIENCE_ALPHA)
              end

              def update_adaptability(tracker)
                rate = tracker.recovery_rate
                signal = tracker.total_adversities.zero? ? 0.5 : rate
                @dimensions[:adaptability] = ema(@dimensions[:adaptability], signal, Constants::RESILIENCE_ALPHA)
              end

              def update_growth(tracker)
                if tracker.consecutive_recoveries >= Constants::GROWTH_TRIGGER
                  @growth_bonus = [@growth_bonus + Constants::GROWTH_INCREMENT, Constants::MAX_GROWTH_BONUS].min
                end

                growth_signal = tracker.total_adversities.zero? ? 0.5 : 0.5 + @growth_bonus
                @dimensions[:growth] = ema(@dimensions[:growth], growth_signal, Constants::RESILIENCE_ALPHA)
              end

              def dimension_trend(name)
                return :insufficient_data if @history.size < 5

                recent = @history.last(10)
                values = recent.map { |h| h[:dimensions][name] }
                first_half = values[0...(values.size / 2)]
                second_half = values[(values.size / 2)..]
                diff = mean(second_half) - mean(first_half)

                if diff > 0.02
                  :improving
                elsif diff < -0.02
                  :declining
                else
                  :stable
                end
              end

              def ema(current, observed, alpha)
                (current * (1.0 - alpha)) + (observed * alpha)
              end

              def mean(values)
                return 0.0 if values.empty?

                values.sum / values.size.to_f
              end

              def record_snapshot
                @history << {
                  dimensions: @dimensions.dup,
                  composite:  composite_score,
                  class:      classification,
                  at:         Time.now.utc
                }
                @history.shift while @history.size > Constants::MAX_RESILIENCE_HISTORY
              end
            end
          end
        end
      end
    end
  end
end
