# frozen_string_literal: true

require 'legion/extensions/agentic/affect/reward/helpers/constants'
require 'legion/extensions/agentic/affect/reward/helpers/reward_signal'
require 'legion/extensions/agentic/affect/reward/helpers/reward_store'
require 'legion/extensions/agentic/affect/reward/runners/reward'

module Legion
  module Extensions
    module Agentic
      module Affect
        module Reward
          class Client
            include Legion::Extensions::Helpers::Lex
            include Runners::Reward

            attr_reader :reward_store

            def initialize(reward_store: nil, **)
              @reward_store = reward_store || Helpers::RewardStore.new
            end
          end
        end
      end
    end
  end
end
