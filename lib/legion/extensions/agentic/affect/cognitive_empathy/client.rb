# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module CognitiveEmpathy
          class Client
            include Legion::Extensions::Helpers::Lex
            include Runners::CognitiveEmpathy

            def initialize(engine: nil)
              @engine = engine || Helpers::EmpathyEngine.new
            end
          end
        end
      end
    end
  end
end
