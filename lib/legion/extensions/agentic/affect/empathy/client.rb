# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Affect
        module Empathy
          class Client
            include Legion::Extensions::Helpers::Lex
            include Runners::Empathy

            attr_reader :model_store

            def initialize(model_store: nil, **)
              @model_store = model_store || Helpers::ModelStore.new
            end
          end
        end
      end
    end
  end
end
