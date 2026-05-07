# frozen_string_literal: true

require 'legion/extensions/agentic/affect/emotion/helpers/valence'
require 'legion/extensions/agentic/affect/emotion/helpers/baseline'
require 'legion/extensions/agentic/affect/emotion/helpers/momentum'
require 'legion/extensions/agentic/affect/emotion/runners/valence'
require 'legion/extensions/agentic/affect/emotion/runners/gut'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Emotion
          class Client
            include Legion::Extensions::Helpers::Lex
            include Runners::Valence
            include Runners::Gut

            def initialize(**)
              @emotion_baseline = Helpers::Baseline.new
              @emotion_momentum = Helpers::Momentum.new
            end

            def track_domain(domain)
              domain_counts[domain] += 1
            end

            private

            attr_reader :emotion_baseline, :emotion_momentum
          end
        end
      end
    end
  end
end
