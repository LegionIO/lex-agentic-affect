# frozen_string_literal: true

require 'legion/extensions/agentic/affect/regulation/helpers/constants'
require 'legion/extensions/agentic/affect/regulation/helpers/regulation_model'
require 'legion/extensions/agentic/affect/regulation/runners/emotional_regulation'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Regulation
          class Client
            include Legion::Extensions::Helpers::Lex
            include Runners::EmotionalRegulation

            attr_reader :regulation_model

            def initialize(regulation_model: nil, **)
              @regulation_model = regulation_model || Helpers::RegulationModel.new
            end
          end
        end
      end
    end
  end
end
