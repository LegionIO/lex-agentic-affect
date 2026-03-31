# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Empathy
          module Helpers
            class ModelStore
              attr_reader :models

              def initialize
                @models = {}
                @dirty = false
              end

              def get(agent_id)
                @models[agent_id.to_s]
              end

              def get_or_create(agent_id)
                key = agent_id.to_s
                @models[key] ||= MentalModel.new(agent_id: key)
              end

              def update(agent_id, observation)
                model = get_or_create(agent_id)
                model.update_from_observation(observation)
                evict_if_needed
                model
              end

              def update_from_human_observation(observation)
                identity   = observation[:identity].to_s
                bond_role  = observation[:bond_role] || :unknown
                channel    = observation[:channel]

                key = identity
                model = @models[key] ||= MentalModel.new(agent_id: key, bond_role: bond_role, channel: channel)
                evidence = bond_role == :partner ? 0.8 : 0.5
                model.update_from_observation(
                  interaction_type:  :human_observation,
                  evidence_strength: evidence,
                  summary:           "channel=#{channel} content_type=#{observation[:content_type]} " \
                                     "length=#{observation[:content_length]}"
                )
                evict_if_needed
                @dirty = true
                model
              end

              def dirty?
                @dirty
              end

              def mark_clean!
                @dirty = false
              end

              def to_apollo_entries
                @models.values.map do |model|
                  data = model.to_h.merge(
                    created_at: model.created_at.iso8601,
                    updated_at: model.updated_at.iso8601
                  )
                  {
                    content: ::JSON.generate(data.transform_keys(&:to_s)),
                    tags:    ['empathy', 'mental_model', model.agent_id]
                  }
                end
              end

              def from_apollo(store:)
                entries = store.query(tags: %w[empathy mental_model])
                entries.each do |entry|
                  data = ::JSON.parse(entry[:content])
                  agent_id = data['agent_id']
                  next unless agent_id

                  bond_role  = data['bond_role']&.to_sym || :unknown
                  channel    = data['channel']&.to_sym
                  confidence = data['confidence_level']

                  model = MentalModel.new(agent_id: agent_id, bond_role: bond_role,
                                          channel: channel, confidence: confidence)
                  @models[agent_id] = model
                rescue ::JSON::ParserError => e
                  warn "[empathy] from_apollo: skipping invalid entry: #{e.message}"
                  next
                end
              end

              def predict(agent_id, scenario)
                model = get(agent_id)
                return nil unless model

                model.predict_reaction(scenario)
              end

              def decay_all
                count = 0
                @models.each_value do |model|
                  model.decay
                  count += 1
                end
                count
              end

              def remove_stale
                stale_keys = @models.select { |_, m| m.stale? && m.interaction_history.empty? }.keys
                stale_keys.each { |k| @models.delete(k) }
                stale_keys.size
              end

              def all_models
                @models.values
              end

              def by_cooperation(stance)
                @models.values.select { |m| m.cooperation_stance == stance }
              end

              def by_emotion(emotion)
                @models.values.select { |m| m.emotional_state == emotion }
              end

              def size
                @models.size
              end

              def clear
                @models.clear
              end

              private

              def evict_if_needed
                return unless @models.size > Constants::MAX_TRACKED_AGENTS

                oldest = @models.min_by { |_, m| m.updated_at }
                @models.delete(oldest[0]) if oldest
              end
            end
          end
        end
      end
    end
  end
end
