# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Fatigue
          module Actor
            class UpdateFatigue < Legion::Extensions::Actors::Every # rubocop:disable Legion/Extension/EveryActorRequiresTime
              def runner_class
                Legion::Extensions::Agentic::Affect::Fatigue::Runners::Fatigue
              end

              def runner_function
                'update_fatigue'
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
