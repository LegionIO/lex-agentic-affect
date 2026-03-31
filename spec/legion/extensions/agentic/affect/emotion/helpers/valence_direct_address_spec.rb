# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Emotion::Helpers::Valence do
  describe 'SOURCE_URGENCY' do
    it 'includes :direct_address with urgency 0.8' do
      expect(described_class::SOURCE_URGENCY[:direct_address]).to eq(0.8)
    end
  end
end
