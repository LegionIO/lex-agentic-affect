# frozen_string_literal: true

module Legion
  module Extensions
    module Actors
      class Every; end # rubocop:disable Lint/EmptyClass
    end
  end
end

$LOADED_FEATURES << 'legion/extensions/actors/every'

require_relative '../../../../../../../lib/legion/extensions/agentic/affect/empathy/actors/decay_models'

RSpec.describe Legion::Extensions::Agentic::Affect::Empathy::Actor::DecayModels do
  subject(:actor) { described_class.new }

  describe '#runner_class' do
    it { expect(actor.runner_class).to eq Legion::Extensions::Agentic::Affect::Empathy::Runners::Empathy }
  end

  describe '#runner_function' do
    it { expect(actor.runner_function).to eq 'decay_models' }
  end

  describe '#time' do
    it { expect(actor.time).to eq 300 }
  end

  describe '#run_now?' do
    it { expect(actor.run_now?).to be false }
  end

  describe '#use_runner?' do
    it { expect(actor.use_runner?).to be false }
  end

  describe '#check_subtask?' do
    it { expect(actor.check_subtask?).to be false }
  end

  describe '#generate_task?' do
    it { expect(actor.generate_task?).to be false }
  end
end
