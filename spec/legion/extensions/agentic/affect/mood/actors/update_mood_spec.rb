# frozen_string_literal: true

module Legion
  module Extensions
    module Actors
      class Every # rubocop:disable Lint/EmptyClass
      end
    end
  end
end

$LOADED_FEATURES << 'legion/extensions/actors/every'

require_relative '../../../../../../../lib/legion/extensions/agentic/affect/mood/actors/update_mood'

RSpec.describe Legion::Extensions::Agentic::Affect::Mood::Actor::UpdateMood do
  subject(:actor) { described_class.new }

  describe '#runner_class' do
    it { expect(actor.runner_class).to eq Legion::Extensions::Agentic::Affect::Mood::Runners::Mood }
  end

  describe '#runner_function' do
    it { expect(actor.runner_function).to eq 'update_mood' }
  end

  describe '#time' do
    it { expect(actor.time).to eq 60 }
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
