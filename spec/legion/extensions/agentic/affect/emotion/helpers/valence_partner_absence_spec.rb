# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Emotion::Helpers::Valence do
  describe 'SOURCE_URGENCY' do
    it 'includes :partner_absence with urgency 0.2' do
      expect(described_class::SOURCE_URGENCY[:partner_absence]).to eq(0.2)
    end
  end

  describe '.absence_importance' do
    it 'returns base importance for a single miss' do
      result = described_class.absence_importance(1)
      expected = 0.4 + (0.1 * Math.log(2))
      expect(result).to be_within(0.001).of(expected)
    end

    it 'scales logarithmically with consecutive misses' do
      low = described_class.absence_importance(1)
      mid = described_class.absence_importance(10)
      high = described_class.absence_importance(50)
      expect(mid).to be > low
      expect(high).to be > mid
    end

    it 'caps at ABSENCE_MAX_IMPORTANCE' do
      result = described_class.absence_importance(10_000)
      expect(result).to eq(described_class::ABSENCE_MAX_IMPORTANCE)
    end

    it 'returns base importance for zero misses' do
      result = described_class.absence_importance(0)
      expect(result).to be_within(0.001).of(described_class::ABSENCE_BASE_IMPORTANCE)
    end
  end
end
