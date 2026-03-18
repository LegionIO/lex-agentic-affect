# frozen_string_literal: true

require 'legion/extensions/agentic/affect/fatigue/helpers/constants'
require 'legion/extensions/agentic/affect/fatigue/helpers/energy_model'
require 'legion/extensions/agentic/affect/fatigue/helpers/fatigue_store'
require 'legion/extensions/agentic/affect/fatigue/runners/fatigue'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Fatigue
          class Client
            include Runners::Fatigue

            attr_reader :fatigue_store

            def initialize(fatigue_store: nil, **)
              @fatigue_store = fatigue_store || Helpers::FatigueStore.new
            end
          end
        end
      end
    end
  end
end
