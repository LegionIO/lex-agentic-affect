# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Interoception
          module Helpers
            class BodyBudget
              include Constants

              attr_reader :vitals, :baselines, :markers, :vital_history

              def initialize
                @vitals        = {}
                @baselines     = {}
                @markers       = []
                @vital_history = {}
              end

              # --- Vital Signal Tracking ---

              def report_vital(channel:, value:)
                channel = channel.to_sym
                return nil unless VITAL_CHANNELS.include?(channel)

                normalized = value.clamp(0.0, 1.0)
                @baselines[channel] ||= DEFAULT_BASELINE
                @vitals[channel] = if @vitals.key?(channel)
                                     ema(@vitals[channel], normalized, VITAL_ALPHA)
                                   else
                                     normalized
                                   end
                record_vital_history(channel, @vitals[channel])
                @baselines[channel] = ema(@baselines[channel], @vitals[channel], VITAL_ALPHA * 0.5)
                @vitals[channel]
              end

              def vital_for(channel)
                @vitals.fetch(channel.to_sym, DEFAULT_BASELINE)
              end

              def deviation_for(channel)
                channel = channel.to_sym
                current = @vitals.fetch(channel, DEFAULT_BASELINE)
                baseline = @baselines.fetch(channel, DEFAULT_BASELINE)
                current - baseline
              end

              def vital_label(channel)
                health = vital_health(channel)
                VITAL_LABELS.each { |range, lbl| return lbl if range.cover?(health) }
                :nominal
              end

              def vital_health(channel)
                val = vital_for(channel)
                inverted_channels = %i[cpu_load memory_pressure queue_depth error_rate disk_usage gc_pressure]
                inverted_channels.include?(channel.to_sym) ? 1.0 - val : val
              end

              def deviating_channels
                @vitals.select { |ch, _| deviation_for(ch).abs >= DEVIATION_THRESHOLD }
                       .map { |ch, _| { channel: ch, deviation: deviation_for(ch).round(4), label: vital_label(ch) } }
              end

              # --- Somatic Markers ---

              def create_marker(action:, domain:, valence:, strength: 1.0)
                marker = SomaticMarker.new(action: action, domain: domain, valence: valence, strength: strength)
                @markers << marker
                prune_markers if @markers.size > MAX_MARKERS
                marker
              end

              def markers_for(action:, domain: nil)
                results = @markers.select { |m| m.action == action }
                results = results.select { |m| m.domain == domain } if domain
                results
              end

              def bias_for_action(action:, domain: nil)
                relevant = markers_for(action: action, domain: domain)
                return 0.0 if relevant.empty?

                relevant.sum { |m| m.bias_for(action) } / relevant.size
              end

              def reinforce_markers(action:, domain: nil, amount: 0.1)
                markers_for(action: action, domain: domain).each { |m| m.reinforce(amount: amount) }
              end

              def decay_markers
                @markers.each(&:decay)
                @markers.reject!(&:faded?)
              end

              # --- Body Budget Overview ---

              def overall_health
                return DEFAULT_BASELINE if @vitals.empty?

                healths = @vitals.keys.map { |ch| vital_health(ch) }
                healths.sum / healths.size
              end

              def body_budget_label
                health = overall_health
                BODY_BUDGET_LABELS.each { |range, lbl| return lbl if range.cover?(health) }
                :comfortable
              end

              def channel_count
                @vitals.size
              end

              def marker_count
                @markers.size
              end

              def to_h
                {
                  overall_health:    overall_health.round(4),
                  body_budget_label: body_budget_label,
                  channels:          channel_count,
                  markers:           marker_count,
                  vitals:            @vitals.transform_values { |v| v.round(4) },
                  deviations:        deviating_channels
                }
              end

              private

              def ema(old_val, new_val, alpha)
                old_val + (alpha * (new_val - old_val))
              end

              def record_vital_history(channel, value)
                @vital_history[channel] ||= []
                @vital_history[channel] << { value: value, at: Time.now.utc }
                @vital_history[channel].shift while @vital_history[channel].size > MAX_VITAL_HISTORY
              end

              def prune_markers
                @markers.sort_by!(&:strength)
                @markers.shift while @markers.size > MAX_MARKERS
              end
            end
          end
        end
      end
    end
  end
end
