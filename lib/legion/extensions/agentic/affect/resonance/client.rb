# frozen_string_literal: true

require 'legion/extensions/agentic/affect/resonance/helpers/constants'
require 'legion/extensions/agentic/affect/resonance/helpers/category'
require 'legion/extensions/agentic/affect/resonance/helpers/resonance_engine'
require 'legion/extensions/agentic/affect/resonance/runners/cognitive_resonance'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Resonance
          class Client
            include Legion::Extensions::Helpers::Lex
            include Runners::CognitiveResonance

            def initialize(**)
              @default_engine = Helpers::ResonanceEngine.new
            end
          end
        end
      end
    end
  end
end
