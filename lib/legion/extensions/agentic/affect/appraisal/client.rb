# frozen_string_literal: true

require 'legion/extensions/agentic/affect/appraisal/helpers/constants'
require 'legion/extensions/agentic/affect/appraisal/helpers/appraisal'
require 'legion/extensions/agentic/affect/appraisal/helpers/appraisal_engine'
require 'legion/extensions/agentic/affect/appraisal/runners/appraisal'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Appraisal
          class Client
            include Runners::Appraisal
          end
        end
      end
    end
  end
end
