# frozen_string_literal: true

require 'legion/extensions/agentic/affect/motivation/helpers/constants'
require 'legion/extensions/agentic/affect/motivation/helpers/drive_state'
require 'legion/extensions/agentic/affect/motivation/helpers/motivation_store'
require 'legion/extensions/agentic/affect/motivation/runners/motivation'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Motivation
          class Client
            include Legion::Extensions::Helpers::Lex
            include Runners::Motivation

            attr_reader :motivation_store

            def initialize(motivation_store: nil, **)
              @motivation_store = motivation_store || Helpers::MotivationStore.new
            end
          end
        end
      end
    end
  end
end
