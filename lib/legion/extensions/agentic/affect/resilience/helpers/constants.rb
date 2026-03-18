# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Resilience
          module Helpers
            module Constants
              # Adversity types the resilience system tracks
              ADVERSITY_TYPES = %i[
                prediction_failure
                trust_violation
                conflict_escalation
                resource_depletion
                communication_failure
                goal_failure
                emotional_shock
                system_error
              ].freeze

              # Recovery phases (Masten's resilience model)
              RECOVERY_PHASES = %i[
                absorbing
                adapting
                recovering
                thriving
              ].freeze

              # Resilience dimensions
              DIMENSIONS = {
                elasticity:   { description: 'Speed of recovery to baseline', weight: 0.30 },
                robustness:   { description: 'Resistance to initial disruption', weight: 0.25 },
                adaptability: { description: 'Capacity to adjust strategy', weight: 0.25 },
                growth:       { description: 'Ability to improve from adversity', weight: 0.20 }
              }.freeze

              # EMA alpha for resilience dimension tracking
              RESILIENCE_ALPHA = 0.08

              # Growth bonus per successful recovery
              GROWTH_INCREMENT = 0.02

              # Maximum growth bonus (anti-fragile ceiling)
              MAX_GROWTH_BONUS = 0.3

              # Adversity severity levels
              SEVERITY_LEVELS = {
                minor:    { impact: 0.1, recovery_ticks: 5 },
                moderate: { impact: 0.3, recovery_ticks: 15 },
                major:    { impact: 0.5, recovery_ticks: 30 },
                severe:   { impact: 0.8, recovery_ticks: 60 },
                critical: { impact: 1.0, recovery_ticks: 100 }
              }.freeze

              # Threshold for considering recovery complete
              RECOVERY_THRESHOLD = 0.9

              # Maximum active adversity events tracked
              MAX_ACTIVE_ADVERSITIES = 20

              # History cap
              MAX_RESILIENCE_HISTORY = 200

              # Fragility threshold — below this, the system is fragile
              FRAGILITY_THRESHOLD = 0.3

              # Anti-fragility threshold — above this, the system grows from stress
              ANTIFRAGILITY_THRESHOLD = 0.7

              # Consecutive recoveries needed to boost growth dimension
              GROWTH_TRIGGER = 3
            end
          end
        end
      end
    end
  end
end
