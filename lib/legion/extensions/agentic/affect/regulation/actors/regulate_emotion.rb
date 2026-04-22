# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Regulation
          module Actor
            # Periodic emotional regulation maintenance actor.
            # Calls update_emotional_regulation which performs skill decay — no live emotion
            # inputs are required. regulate_emotion itself requires emotion_magnitude: and
            # cannot be safely invoked as a background tick without a signal source.
            class RegulateEmotion < Legion::Extensions::Actors::Every # rubocop:disable Legion/Extension/EveryActorRequiresTime
              def runner_class
                Legion::Extensions::Agentic::Affect::Regulation::Runners::EmotionalRegulation
              end

              def runner_function
                'update_emotional_regulation'
              end

              def time
                60
              end

              def run_now?
                false
              end

              def use_runner?
                false
              end

              def check_subtask?
                false
              end

              def generate_task?
                false
              end
            end
          end
        end
      end
    end
  end
end
