# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        # PersonalityState models the Big Five (OCEAN) personality dimensions as global
        # affect modifiers. Traits persist to Apollo Local tagged ['personality', 'ocean', 'global'].
        class PersonalityState
          TRAITS = %i[openness conscientiousness extraversion agreeableness neuroticism].freeze
          DIRTY_THRESHOLD = 0.02

          attr_reader(*TRAITS)

          def initialize
            TRAITS.each { |t| instance_variable_set(:"@#{t}", 0.5) }
            @dirty = false
            @last_persisted = snapshot
          end

          def update_trait(trait, value)
            return unless TRAITS.include?(trait)

            clamped = value.to_f.clamp(0.0, 1.0)
            instance_variable_set(:"@#{trait}", clamped)
            @dirty = true if (clamped - @last_persisted[trait]).abs >= DIRTY_THRESHOLD
          end

          def dirty?
            @dirty
          end

          def mark_clean!
            @dirty = false
            @last_persisted = snapshot
          end

          def to_apollo_entries
            [{
              content: ::JSON.generate(to_h.transform_keys(&:to_s)),
              tags:    %w[personality ocean global]
            }]
          end

          def from_apollo(store:)
            entries = store.query(tags: %w[personality ocean global])
            return if entries.empty?

            data = ::JSON.parse(entries.first[:content])
            TRAITS.each do |trait|
              val = data[trait.to_s]
              instance_variable_set(:"@#{trait}", val.to_f.clamp(0.0, 1.0)) if val
            end
            @last_persisted = snapshot
            @dirty = false
          rescue ::JSON::ParserError => e
            warn "[personality_state] from_apollo: invalid entry: #{e.message}"
          end

          def to_h
            TRAITS.to_h { |t| [t, instance_variable_get(:"@#{t}")] }
          end

          private

          def snapshot
            TRAITS.to_h { |t| [t, instance_variable_get(:"@#{t}")] }
          end
        end
      end
    end
  end
end
