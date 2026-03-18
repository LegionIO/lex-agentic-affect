# frozen_string_literal: true

require 'legion/extensions/agentic/affect/somatic_marker/helpers/constants'
require 'legion/extensions/agentic/affect/somatic_marker/helpers/somatic_marker'
require 'legion/extensions/agentic/affect/somatic_marker/helpers/body_state'
require 'legion/extensions/agentic/affect/somatic_marker/helpers/marker_store'
require 'legion/extensions/agentic/affect/somatic_marker/runners/somatic_marker'

module Legion
  module Extensions
    module Agentic
      module Affect
        module SomaticMarker
          class Client
            include Runners::SomaticMarker

            def initialize(**)
              @store = Helpers::MarkerStore.new
            end

            private

            attr_reader :store
          end
        end
      end
    end
  end
end
