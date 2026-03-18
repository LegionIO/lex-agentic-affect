# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Interoception::Helpers::SomaticMarker do
  subject(:marker) { described_class.new(action: :deploy, domain: :production, valence: 0.6) }

  describe '#initialize' do
    it 'assigns fields' do
      expect(marker.action).to eq(:deploy)
      expect(marker.domain).to eq(:production)
      expect(marker.valence).to eq(0.6)
      expect(marker.strength).to eq(1.0)
    end

    it 'assigns uuid and timestamp' do
      expect(marker.id).to match(/\A[0-9a-f-]{36}\z/)
      expect(marker.created_at).to be_a(Time)
    end

    it 'clamps valence to -1.0..1.0' do
      high = described_class.new(action: :a, domain: :d, valence: 2.0)
      low  = described_class.new(action: :a, domain: :d, valence: -2.0)
      expect(high.valence).to eq(1.0)
      expect(low.valence).to eq(-1.0)
    end

    it 'clamps strength to 0.0..1.0' do
      high = described_class.new(action: :a, domain: :d, valence: 0.5, strength: 5.0)
      expect(high.strength).to eq(1.0)
    end
  end

  describe '#bias_for' do
    it 'returns positive bias for matching action with positive valence' do
      bias = marker.bias_for(:deploy)
      expect(bias).to be > 0
    end

    it 'returns 0 for non-matching action' do
      expect(marker.bias_for(:rollback)).to eq(0.0)
    end

    it 'applies MARKER_INFLUENCE factor' do
      influence = Legion::Extensions::Agentic::Affect::Interoception::Helpers::Constants::MARKER_INFLUENCE
      expected = marker.valence * marker.strength * influence
      expect(marker.bias_for(:deploy)).to be_within(0.001).of(expected)
    end
  end

  describe '#reinforce' do
    it 'increases strength' do
      marker.strength = 0.5
      marker.reinforce(amount: 0.2)
      expect(marker.strength).to be_within(0.001).of(0.7)
    end

    it 'caps at 1.0' do
      marker.reinforce(amount: 0.5)
      expect(marker.strength).to eq(1.0)
    end
  end

  describe '#decay' do
    it 'reduces strength by MARKER_DECAY' do
      before = marker.strength
      marker.decay
      decay_amount = Legion::Extensions::Agentic::Affect::Interoception::Helpers::Constants::MARKER_DECAY
      expect(marker.strength).to be_within(0.001).of(before - decay_amount)
    end

    it 'does not drop below MARKER_FLOOR' do
      50.times { marker.decay }
      expect(marker.strength).to be >= Legion::Extensions::Agentic::Affect::Interoception::Helpers::Constants::MARKER_FLOOR
    end
  end

  describe '#faded?' do
    it 'returns false for strong markers' do
      expect(marker.faded?).to be false
    end

    it 'returns true at or below floor' do
      marker.strength = Legion::Extensions::Agentic::Affect::Interoception::Helpers::Constants::MARKER_FLOOR
      expect(marker.faded?).to be true

      marker.strength = Legion::Extensions::Agentic::Affect::Interoception::Helpers::Constants::MARKER_FLOOR + 0.01
      expect(marker.faded?).to be false
    end
  end

  describe '#positive? / #negative? / #label' do
    it 'returns :approach for positive valence' do
      pos = described_class.new(action: :a, domain: :d, valence: 0.5)
      expect(pos.positive?).to be true
      expect(pos.negative?).to be false
      expect(pos.label).to eq(:approach)
    end

    it 'returns :avoid for negative valence' do
      neg = described_class.new(action: :a, domain: :d, valence: -0.5)
      expect(neg.positive?).to be false
      expect(neg.negative?).to be true
      expect(neg.label).to eq(:avoid)
    end

    it 'returns :neutral for middle valence' do
      mid = described_class.new(action: :a, domain: :d, valence: 0.0)
      expect(mid.positive?).to be false
      expect(mid.negative?).to be false
      expect(mid.label).to eq(:neutral)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all fields' do
      h = marker.to_h
      expect(h).to include(:id, :action, :domain, :valence, :strength, :label, :created_at)
      expect(h[:action]).to eq(:deploy)
    end
  end
end
