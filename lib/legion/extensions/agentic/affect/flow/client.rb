# frozen_string_literal: true

require 'legion/extensions/agentic/affect/flow/helpers/constants'
require 'legion/extensions/agentic/affect/flow/helpers/flow_detector'
require 'legion/extensions/agentic/affect/flow/runners/flow'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Flow
          class Client
            include Runners::Flow

            attr_reader :flow_detector

            def initialize(flow_detector: nil, **)
              @flow_detector = flow_detector || Helpers::FlowDetector.new
            end
          end
        end
      end
    end
  end
end
