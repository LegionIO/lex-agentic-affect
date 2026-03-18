# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Interoception
          module Helpers
            module Constants
              # Vital signal channels the agent monitors
              VITAL_CHANNELS = %i[
                cpu_load memory_pressure queue_depth
                response_latency error_rate connection_health
                disk_usage thread_count gc_pressure
              ].freeze

              # Somatic marker valence thresholds
              MARKER_POSITIVE_THRESHOLD = 0.3
              MARKER_NEGATIVE_THRESHOLD = -0.3

              # How strongly markers bias decisions (0..1)
              MARKER_INFLUENCE = 0.4

              # EMA alpha for vital signal smoothing
              VITAL_ALPHA = 0.15

              # Default baseline for vitals (normalized 0..1)
              DEFAULT_BASELINE = 0.5

              # Deviation from baseline that triggers a somatic marker
              DEVIATION_THRESHOLD = 0.2

              # Maximum stored somatic markers
              MAX_MARKERS = 200

              # Maximum stored vital snapshots per channel
              MAX_VITAL_HISTORY = 100

              # Marker decay per tick
              MARKER_DECAY = 0.02

              # Marker floor (below this, marker is pruned)
              MARKER_FLOOR = 0.05

              # Body budget labels based on overall vital health
              BODY_BUDGET_LABELS = {
                (0.8..)     => :thriving,
                (0.6...0.8) => :comfortable,
                (0.4...0.6) => :strained,
                (0.2...0.4) => :distressed,
                (..0.2)     => :critical
              }.freeze

              # Vital health labels
              VITAL_LABELS = {
                (0.8..)     => :healthy,
                (0.6...0.8) => :nominal,
                (0.4...0.6) => :elevated,
                (0.2...0.4) => :warning,
                (..0.2)     => :critical
              }.freeze
            end
          end
        end
      end
    end
  end
end
