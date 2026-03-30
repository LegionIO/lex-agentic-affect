# frozen_string_literal: true

require 'legion/extensions/agentic/affect/defusion/helpers/constants'
require 'legion/extensions/agentic/affect/defusion/helpers/thought'
require 'legion/extensions/agentic/affect/defusion/helpers/defusion_engine'
require 'legion/extensions/agentic/affect/defusion/runners/cognitive_defusion'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Defusion
          class Client
            include Legion::Extensions::Helpers::Lex
            include Runners::CognitiveDefusion

            def initialize(engine: nil)
              @defusion_engine = engine || Helpers::DefusionEngine.new
            end

            private

            attr_reader :defusion_engine
          end
        end
      end
    end
  end
end
