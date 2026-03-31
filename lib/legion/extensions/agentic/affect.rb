# frozen_string_literal: true

require_relative 'affect/version'
require_relative 'affect/personality_state'
require_relative 'affect/cognitive_empathy'
require_relative 'affect/reappraisal'
require_relative 'affect/defusion'
require_relative 'affect/contagion'
require_relative 'affect/emotion'
require_relative 'affect/regulation'
require_relative 'affect/mood'
require_relative 'affect/appraisal'
require_relative 'affect/empathy'
require_relative 'affect/somatic_marker'
require_relative 'affect/interoception'
require_relative 'affect/flow'
require_relative 'affect/fatigue'
require_relative 'affect/motivation'
require_relative 'affect/reward'
require_relative 'affect/resilience'
require_relative 'affect/resonance'

module Legion
  module Extensions
    module Agentic
      module Affect
        extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core, false

        def self.remote_invocable?
          false
        end
      end
    end
  end
end
