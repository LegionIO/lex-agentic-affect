# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Appraisal
          module Runners
            module Appraisal
              extend self

              def appraise_event(event:, primary:, secondary:, domain: nil, **)
                log.debug("[lex-appraisal] appraise_event event=#{event} domain=#{domain}")
                record = engine.appraise(event: event, primary: primary, secondary: secondary, domain: domain)
                { success: true, appraisal: record.to_h }
              rescue StandardError => e
                log.error("[lex-appraisal] appraise_event error: #{e.message}")
                { success: false, error: e.message }
              end

              def reappraise_event(appraisal_id:, new_primary:, new_secondary:, **)
                log.debug("[lex-appraisal] reappraise_event id=#{appraisal_id}")
                record = engine.reappraise(appraisal_id: appraisal_id, new_primary: new_primary,
                                           new_secondary: new_secondary)
                return { success: false, error: 'appraisal not found' } unless record

                { success: true, appraisal: record.to_h }
              rescue StandardError => e
                log.error("[lex-appraisal] reappraise_event error: #{e.message}")
                { success: false, error: e.message }
              end

              def select_coping_strategy(appraisal_id:, coping_type:, **)
                log.debug("[lex-appraisal] select_coping appraisal_id=#{appraisal_id}")
                record = engine.select_coping(appraisal_id: appraisal_id, coping_type: coping_type)
                return { success: false, error: 'appraisal not found' } unless record

                { success: true, appraisal: record.to_h }
              rescue StandardError => e
                log.error("[lex-appraisal] select_coping error: #{e.message}")
                { success: false, error: e.message }
              end

              def add_coping_strategy(name:, coping_type:, effectiveness:, **)
                log.debug("[lex-appraisal] add_coping_strategy name=#{name}")
                added = engine.add_coping_strategy(name: name, coping_type: coping_type, effectiveness: effectiveness)
                { success: added, name: name, coping_type: coping_type }
              rescue StandardError => e
                log.error("[lex-appraisal] add_coping_strategy error: #{e.message}")
                { success: false, error: e.message }
              end

              def evaluate_coping(appraisal_id:, **)
                log.debug("[lex-appraisal] evaluate_coping id=#{appraisal_id}")
                result = engine.evaluate_coping(appraisal_id: appraisal_id)
                { success: true }.merge(result)
              rescue StandardError => e
                log.error("[lex-appraisal] evaluate_coping error: #{e.message}")
                { success: false, error: e.message }
              end

              def emotional_pattern(**)
                log.debug('[lex-appraisal] emotional_pattern')
                pattern = engine.emotional_pattern
                { success: true, pattern: pattern }
              rescue StandardError => e
                log.error("[lex-appraisal] emotional_pattern error: #{e.message}")
                { success: false, error: e.message }
              end

              def update_appraisal(**)
                log.debug('[lex-appraisal] update_appraisal (decay cycle)')
                engine.decay_all
                { success: true }
              rescue StandardError => e
                log.error("[lex-appraisal] update_appraisal error: #{e.message}")
                { success: false, error: e.message }
              end

              def appraisal_stats(**)
                log.debug('[lex-appraisal] appraisal_stats')
                data = engine.to_h
                unresolved = engine.unresolved.size
                {
                  success:      true,
                  total:        data[:appraisals].size,
                  unresolved:   unresolved,
                  history_size: data[:history_size],
                  pattern:      engine.emotional_pattern
                }
              rescue StandardError => e
                log.error("[lex-appraisal] appraisal_stats error: #{e.message}")
                { success: false, error: e.message }
              end

              private

              def engine
                @engine ||= Helpers::AppraisalEngine.new
              end
            end
          end
        end
      end
    end
  end
end
