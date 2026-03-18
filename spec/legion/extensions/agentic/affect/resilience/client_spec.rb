# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Agentic::Affect::Resilience::Client do
  describe '#initialize' do
    it 'creates default adversity tracker and model' do
      client = described_class.new
      expect(client.adversity_tracker).to be_a(Legion::Extensions::Agentic::Affect::Resilience::Helpers::AdversityTracker)
      expect(client.resilience_model).to be_a(Legion::Extensions::Agentic::Affect::Resilience::Helpers::ResilienceModel)
    end

    it 'accepts injected dependencies' do
      tracker = Legion::Extensions::Agentic::Affect::Resilience::Helpers::AdversityTracker.new
      model = Legion::Extensions::Agentic::Affect::Resilience::Helpers::ResilienceModel.new
      client = described_class.new(adversity_tracker: tracker, resilience_model: model)
      expect(client.adversity_tracker).to be(tracker)
      expect(client.resilience_model).to be(model)
    end

    it 'ignores unknown kwargs' do
      expect { described_class.new(unknown: true) }.not_to raise_error
    end
  end

  describe 'runner integration' do
    let(:client) { described_class.new }

    it { expect(client).to respond_to(:update_resilience) }
    it { expect(client).to respond_to(:register_adversity) }
    it { expect(client).to respond_to(:resilience_status) }
    it { expect(client).to respond_to(:adversity_report) }
    it { expect(client).to respond_to(:dimension_detail) }
    it { expect(client).to respond_to(:resilience_stats) }
  end
end
