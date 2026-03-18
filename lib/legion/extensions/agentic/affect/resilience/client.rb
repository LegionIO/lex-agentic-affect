# frozen_string_literal: true

require 'legion/extensions/agentic/affect/resilience/helpers/constants'
require 'legion/extensions/agentic/affect/resilience/helpers/adversity_tracker'
require 'legion/extensions/agentic/affect/resilience/helpers/resilience_model'
require 'legion/extensions/agentic/affect/resilience/runners/resilience'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Resilience
          class Client
            include Runners::Resilience

            attr_reader :adversity_tracker, :resilience_model

            def initialize(adversity_tracker: nil, resilience_model: nil, **)
              @adversity_tracker = adversity_tracker || Helpers::AdversityTracker.new
              @resilience_model = resilience_model || Helpers::ResilienceModel.new
            end
          end
        end
      end
    end
  end
end
