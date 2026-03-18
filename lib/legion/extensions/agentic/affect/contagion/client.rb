# frozen_string_literal: true

require 'legion/extensions/agentic/affect/contagion/helpers/constants'
require 'legion/extensions/agentic/affect/contagion/helpers/meme'
require 'legion/extensions/agentic/affect/contagion/helpers/contagion_engine'
require 'legion/extensions/agentic/affect/contagion/runners/cognitive_contagion'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Contagion
          class Client
            include Runners::CognitiveContagion

            def initialize(**)
              @engine = Helpers::ContagionEngine.new
            end

            private

            attr_reader :engine
          end
        end
      end
    end
  end
end
