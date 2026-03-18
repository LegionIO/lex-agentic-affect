# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Resilience
          module Helpers
            class AdversityTracker
              attr_reader :active_adversities, :resolved_adversities, :consecutive_recoveries

              def initialize
                @active_adversities = []
                @resolved_adversities = []
                @consecutive_recoveries = 0
                @adversity_counter = 0
              end

              def register(type:, severity:, context: {})
                return nil unless Constants::ADVERSITY_TYPES.include?(type)
                return nil unless Constants::SEVERITY_LEVELS.key?(severity)

                @adversity_counter += 1
                severity_config = Constants::SEVERITY_LEVELS[severity]

                adversity = {
                  id:              @adversity_counter,
                  type:            type,
                  severity:        severity,
                  impact:          severity_config[:impact],
                  expected_ticks:  severity_config[:recovery_ticks],
                  phase:           :absorbing,
                  health_at_onset: 1.0,
                  current_health:  1.0 - severity_config[:impact],
                  ticks_elapsed:   0,
                  context:         context,
                  registered_at:   Time.now.utc
                }

                @active_adversities << adversity
                trim_active
                adversity
              end

              def tick_recovery
                @active_adversities.each do |adv|
                  adv[:ticks_elapsed] += 1
                  advance_phase(adv)
                  recover_health(adv)
                end

                newly_resolved = @active_adversities.select { |a| a[:current_health] >= Constants::RECOVERY_THRESHOLD }
                newly_resolved.each { |a| resolve(a) }

                {
                  active_count:   @active_adversities.size,
                  resolved_count: newly_resolved.size,
                  worst_health:   worst_health
                }
              end

              def worst_health
                return 1.0 if @active_adversities.empty?

                @active_adversities.map { |a| a[:current_health] }.min
              end

              def active_by_type
                @active_adversities.group_by { |a| a[:type] }.transform_values(&:size)
              end

              def recovery_rate
                total = @resolved_adversities.size
                return 0.0 if total.zero?

                on_time = @resolved_adversities.count { |a| a[:ticks_elapsed] <= a[:expected_ticks] }
                on_time.to_f / total
              end

              def average_recovery_speed
                return 0.0 if @resolved_adversities.empty?

                ratios = @resolved_adversities.map { |a| a[:ticks_elapsed].to_f / [a[:expected_ticks], 1].max }
                ratios.sum / ratios.size.to_f
              end

              def total_adversities
                @active_adversities.size + @resolved_adversities.size
              end

              private

              def advance_phase(adv)
                progress = adv[:current_health]
                adv[:phase] = if progress < 0.3
                                :absorbing
                              elsif progress < 0.6
                                :adapting
                              elsif progress < Constants::RECOVERY_THRESHOLD
                                :recovering
                              else
                                :thriving
                              end
              end

              def recover_health(adv)
                recovery_rate = 1.0 / [adv[:expected_ticks], 1].max
                adv[:current_health] = [adv[:current_health] + recovery_rate, 1.0].min
              end

              def resolve(adv)
                adv[:phase] = :thriving
                adv[:resolved_at] = Time.now.utc
                @active_adversities.delete(adv)
                @resolved_adversities << adv
                @resolved_adversities.shift while @resolved_adversities.size > Constants::MAX_RESILIENCE_HISTORY

                @consecutive_recoveries += 1
              end

              def trim_active
                @active_adversities.shift while @active_adversities.size > Constants::MAX_ACTIVE_ADVERSITIES
              end
            end
          end
        end
      end
    end
  end
end
