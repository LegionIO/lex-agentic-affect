# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Flow
          module Actor
            class UpdateFlow < Legion::Extensions::Actors::Every # rubocop:disable Legion/Extension/EveryActorRequiresTime
              def runner_class
                Legion::Extensions::Agentic::Affect::Flow::Runners::Flow
              end

              def runner_function
                'update_flow'
              end

              def time
                30
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
