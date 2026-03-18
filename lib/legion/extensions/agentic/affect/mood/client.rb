# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Mood
          class Client
            include Runners::Mood

            attr_reader :mood_state

            def initialize(mood_state: nil, **)
              @mood_state = mood_state || Helpers::MoodState.new
            end
          end
        end
      end
    end
  end
end
