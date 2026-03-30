# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Interoception
          module Runners
            module Interoception
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def report_vital(channel:, value:, **)
                smoothed = body_budget.report_vital(channel: channel, value: value.to_f)
                return { success: false, error: :invalid_channel, valid_channels: Helpers::Constants::VITAL_CHANNELS } unless smoothed

                deviation = body_budget.deviation_for(channel)
                log.debug("[interoception] vital: channel=#{channel} raw=#{value} " \
                          "smoothed=#{smoothed.round(3)} deviation=#{deviation.round(3)}")
                {
                  success:   true,
                  channel:   channel,
                  smoothed:  smoothed.round(4),
                  deviation: deviation.round(4),
                  label:     body_budget.vital_label(channel)
                }
              end

              def create_somatic_marker(action:, domain:, valence:, strength: 1.0, **)
                marker = body_budget.create_marker(action: action, domain: domain, valence: valence.to_f, strength: strength.to_f)
                log.debug("[interoception] marker: action=#{action} domain=#{domain} " \
                          "valence=#{marker.valence.round(2)} label=#{marker.label}")
                { success: true, marker: marker.to_h }
              end

              def query_bias(action:, domain: nil, **)
                bias = body_budget.bias_for_action(action: action, domain: domain)
                label = if bias > Helpers::Constants::MARKER_POSITIVE_THRESHOLD * Helpers::Constants::MARKER_INFLUENCE
                          :approach
                        elsif bias < Helpers::Constants::MARKER_NEGATIVE_THRESHOLD * Helpers::Constants::MARKER_INFLUENCE
                          :avoid
                        else
                          :neutral
                        end
                log.debug("[interoception] bias: action=#{action} domain=#{domain} bias=#{bias.round(3)} label=#{label}")
                { success: true, action: action, domain: domain, bias: bias.round(4), label: label }
              end

              def reinforce_somatic(action:, domain: nil, amount: 0.1, **)
                body_budget.reinforce_markers(action: action, domain: domain, amount: amount.to_f)
                log.debug("[interoception] reinforce: action=#{action} domain=#{domain} amount=#{amount}")
                { success: true, action: action, domain: domain }
              end

              def deviating_vitals(**)
                deviations = body_budget.deviating_channels
                log.debug("[interoception] deviating: count=#{deviations.size}")
                { success: true, deviations: deviations, count: deviations.size }
              end

              def body_status(**)
                health = body_budget.overall_health
                label = body_budget.body_budget_label
                log.debug("[interoception] status: health=#{health.round(3)} label=#{label}")
                {
                  success:  true,
                  health:   health.round(4),
                  label:    label,
                  channels: body_budget.channel_count,
                  markers:  body_budget.marker_count
                }
              end

              def update_interoception(**)
                body_budget.decay_markers
                health = body_budget.overall_health
                log.debug("[interoception] tick: health=#{health.round(3)} " \
                          "channels=#{body_budget.channel_count} markers=#{body_budget.marker_count}")
                {
                  success:  true,
                  health:   health.round(4),
                  label:    body_budget.body_budget_label,
                  channels: body_budget.channel_count,
                  markers:  body_budget.marker_count
                }
              end

              def interoception_stats(**)
                { success: true, stats: body_budget.to_h }
              end

              private

              def body_budget
                @body_budget ||= Helpers::BodyBudget.new
              end
            end
          end
        end
      end
    end
  end
end
