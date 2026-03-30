# frozen_string_literal: true

require 'legion/extensions/agentic/affect/interoception/helpers/constants'
require 'legion/extensions/agentic/affect/interoception/helpers/somatic_marker'
require 'legion/extensions/agentic/affect/interoception/helpers/body_budget'
require 'legion/extensions/agentic/affect/interoception/runners/interoception'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Interoception
          class Client
            include Legion::Extensions::Helpers::Lex
            include Runners::Interoception

            def initialize(body_budget: nil, **)
              @body_budget = body_budget || Helpers::BodyBudget.new
            end

            private

            attr_reader :body_budget
          end
        end
      end
    end
  end
end
