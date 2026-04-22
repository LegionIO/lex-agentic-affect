# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Resilience
          module Actor
            class UpdateResilience < Legion::Extensions::Actors::Every # rubocop:disable Legion/Extension/EveryActorRequiresTime
              def runner_class
                Legion::Extensions::Agentic::Affect::Resilience::Runners::Resilience
              end

              def runner_function
                'update_resilience'
              end

              def time
                120
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
