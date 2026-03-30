# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Resilience
          module Runners
            module Resilience
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def update_resilience(tick_results: {}, **)
                detect_adversities(tick_results)
                recovery = adversity_tracker.tick_recovery
                resilience_model.update_from_tracker(adversity_tracker)

                log.debug("[resilience] active=#{recovery[:active_count]} " \
                          "resolved=#{recovery[:resolved_count]} " \
                          "composite=#{resilience_model.composite_score.round(3)}")

                {
                  active_adversities: recovery[:active_count],
                  resolved_this_tick: recovery[:resolved_count],
                  worst_health:       recovery[:worst_health],
                  composite_score:    resilience_model.composite_score.round(4),
                  classification:     resilience_model.classification,
                  growth_bonus:       resilience_model.growth_bonus.round(4)
                }
              end

              def register_adversity(type:, severity:, context: {}, **)
                adversity = adversity_tracker.register(type: type, severity: severity, context: context)
                return { success: false, error: 'invalid type or severity' } unless adversity

                log.info("[resilience] adversity registered: type=#{type} severity=#{severity}")
                { success: true, adversity: adversity }
              end

              def resilience_status(**)
                model_state = resilience_model.to_h
                log.debug("[resilience] status: #{model_state[:class]} score=#{model_state[:composite]}")

                model_state.merge(
                  active_adversities:     adversity_tracker.active_adversities.size,
                  total_adversities:      adversity_tracker.total_adversities,
                  consecutive_recoveries: adversity_tracker.consecutive_recoveries,
                  recovery_rate:          adversity_tracker.recovery_rate.round(4)
                )
              end

              def adversity_report(**)
                log.debug('[resilience] adversity report')

                {
                  active:    adversity_tracker.active_adversities,
                  by_type:   adversity_tracker.active_by_type,
                  total:     adversity_tracker.total_adversities,
                  worst:     adversity_tracker.worst_health.round(4),
                  avg_speed: adversity_tracker.average_recovery_speed.round(4)
                }
              end

              def dimension_detail(dimension:, **)
                detail = resilience_model.dimension_detail(dimension.to_sym)
                return { error: "unknown dimension: #{dimension}" } unless detail

                log.debug("[resilience] dimension #{dimension}: #{detail[:value]}")
                detail
              end

              def resilience_stats(**)
                log.debug('[resilience] stats')

                {
                  composite:              resilience_model.composite_score.round(4),
                  classification:         resilience_model.classification,
                  dimensions:             resilience_model.dimensions.transform_values { |v| v.round(4) },
                  growth_bonus:           resilience_model.growth_bonus.round(4),
                  trend:                  resilience_model.trend,
                  total_adversities:      adversity_tracker.total_adversities,
                  active_adversities:     adversity_tracker.active_adversities.size,
                  recovery_rate:          adversity_tracker.recovery_rate.round(4),
                  consecutive_recoveries: adversity_tracker.consecutive_recoveries,
                  history_size:           resilience_model.history.size
                }
              end

              private

              def adversity_tracker
                @adversity_tracker ||= Helpers::AdversityTracker.new
              end

              def resilience_model
                @resilience_model ||= Helpers::ResilienceModel.new
              end

              def detect_adversities(tick_results)
                detect_prediction_adversity(tick_results)
                detect_trust_adversity(tick_results)
                detect_conflict_adversity(tick_results)
                detect_energy_adversity(tick_results)
                detect_emotional_adversity(tick_results)
              end

              def detect_prediction_adversity(tick_results)
                error_rate = tick_results.dig(:prediction_engine, :error_rate)
                return unless error_rate && error_rate > 0.7

                severity = error_rate > 0.9 ? :major : :moderate
                adversity_tracker.register(type: :prediction_failure, severity: severity)
              end

              def detect_trust_adversity(tick_results)
                violation = tick_results.dig(:trust, :violation)
                return unless violation

                adversity_tracker.register(type: :trust_violation, severity: :major)
              end

              def detect_conflict_adversity(tick_results)
                conflict_severity = tick_results.dig(:conflict, :severity)
                return unless conflict_severity && conflict_severity >= 3

                severity = conflict_severity >= 4 ? :severe : :moderate
                adversity_tracker.register(type: :conflict_escalation, severity: severity)
              end

              def detect_energy_adversity(tick_results)
                energy = tick_results.dig(:fatigue, :energy)
                return unless energy && energy < 0.2

                severity = energy < 0.1 ? :major : :moderate
                adversity_tracker.register(type: :resource_depletion, severity: severity)
              end

              def detect_emotional_adversity(tick_results)
                arousal = tick_results.dig(:emotional_evaluation, :arousal)
                return unless arousal && arousal > 0.9

                adversity_tracker.register(type: :emotional_shock, severity: :moderate)
              end
            end
          end
        end
      end
    end
  end
end
