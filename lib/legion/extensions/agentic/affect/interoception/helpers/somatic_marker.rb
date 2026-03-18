# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Interoception
          module Helpers
            class SomaticMarker
              attr_reader :id, :action, :domain, :valence, :created_at
              attr_accessor :strength

              def initialize(action:, domain:, valence:, strength: 1.0)
                @id         = SecureRandom.uuid
                @action     = action
                @domain     = domain
                @valence    = valence.clamp(-1.0, 1.0)
                @strength   = strength.clamp(0.0, 1.0)
                @created_at = Time.now.utc
              end

              def bias_for(candidate_action)
                return 0.0 unless candidate_action == @action

                @valence * @strength * Constants::MARKER_INFLUENCE
              end

              def reinforce(amount: 0.1)
                @strength = [@strength + amount, 1.0].min
              end

              def decay
                @strength = [@strength - Constants::MARKER_DECAY, Constants::MARKER_FLOOR].max
              end

              def faded?
                @strength <= Constants::MARKER_FLOOR
              end

              def positive?
                @valence >= Constants::MARKER_POSITIVE_THRESHOLD
              end

              def negative?
                @valence <= Constants::MARKER_NEGATIVE_THRESHOLD
              end

              def label
                if positive?
                  :approach
                elsif negative?
                  :avoid
                else
                  :neutral
                end
              end

              def to_h
                {
                  id:         @id,
                  action:     @action,
                  domain:     @domain,
                  valence:    @valence,
                  strength:   @strength,
                  label:      label,
                  created_at: @created_at
                }
              end
            end
          end
        end
      end
    end
  end
end
