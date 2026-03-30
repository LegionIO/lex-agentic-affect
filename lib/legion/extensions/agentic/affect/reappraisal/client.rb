# frozen_string_literal: true

require 'legion/extensions/agentic/affect/reappraisal/helpers/constants'
require 'legion/extensions/agentic/affect/reappraisal/helpers/emotional_event'
require 'legion/extensions/agentic/affect/reappraisal/helpers/reappraisal_engine'
require 'legion/extensions/agentic/affect/reappraisal/runners/cognitive_reappraisal'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Reappraisal
          class Client
            include Legion::Extensions::Helpers::Lex
            include Runners::CognitiveReappraisal

            def initialize(engine: nil, **)
              @reappraisal_engine = engine || Helpers::ReappraisalEngine.new
            end

            private

            attr_reader :reappraisal_engine
          end
        end
      end
    end
  end
end
