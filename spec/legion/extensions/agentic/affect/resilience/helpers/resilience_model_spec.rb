# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Agentic::Affect::Resilience::Helpers::ResilienceModel do
  subject(:model) { described_class.new }

  let(:tracker) { Legion::Extensions::Agentic::Affect::Resilience::Helpers::AdversityTracker.new }

  describe '#initialize' do
    it 'starts all dimensions at 0.5' do
      model.dimensions.each_value do |val|
        expect(val).to eq(0.5)
      end
    end

    it 'starts with zero growth bonus' do
      expect(model.growth_bonus).to eq(0.0)
    end

    it 'starts with empty history' do
      expect(model.history).to be_empty
    end
  end

  describe '#update_from_tracker' do
    it 'records a snapshot' do
      model.update_from_tracker(tracker)
      expect(model.history.size).to eq(1)
    end

    it 'updates dimensions' do
      tracker.register(type: :prediction_failure, severity: :moderate)
      5.times { tracker.tick_recovery }
      model.update_from_tracker(tracker)
      changed = model.dimensions.values.any? { |v| (v - 0.5).abs > 0.001 }
      expect(changed).to be true
    end
  end

  describe '#composite_score' do
    it 'starts at approximately 0.5' do
      expect(model.composite_score).to be_within(0.01).of(0.5)
    end

    it 'is between 0.0 and 1.0' do
      expect(model.composite_score).to be_between(0.0, 1.0)
    end
  end

  describe '#classification' do
    it 'starts as resilient (score ~0.5)' do
      expect(model.classification).to eq(:resilient)
    end

    it 'classifies antifragile for high scores' do
      model.dimensions.each_key { |k| model.dimensions[k] = 0.85 }
      expect(model.classification).to eq(:antifragile)
    end

    it 'classifies fragile for low scores' do
      model.dimensions.each_key { |k| model.dimensions[k] = 0.35 }
      expect(model.classification).to eq(:fragile)
    end

    it 'classifies brittle for very low scores' do
      model.dimensions.each_key { |k| model.dimensions[k] = 0.1 }
      expect(model.classification).to eq(:brittle)
    end
  end

  describe '#dimension_detail' do
    it 'returns detail for valid dimension' do
      detail = model.dimension_detail(:elasticity)
      expect(detail).to include(:name, :value, :config, :trend, :healthy)
    end

    it 'returns nil for unknown dimension' do
      expect(model.dimension_detail(:unknown)).to be_nil
    end
  end

  describe '#trend' do
    it 'returns insufficient_data with few entries' do
      expect(model.trend).to eq(:insufficient_data)
    end

    it 'returns a trend with enough data' do
      10.times { model.update_from_tracker(tracker) }
      expect(%i[strengthening weakening stable]).to include(model.trend)
    end
  end

  describe '#to_h' do
    it 'returns complete state hash' do
      h = model.to_h
      expect(h).to include(:dimensions, :growth_bonus, :composite, :class, :trend)
    end
  end

  describe 'growth bonus' do
    it 'increases after consecutive recoveries' do
      tracker.register(type: :prediction_failure, severity: :minor)
      20.times { tracker.tick_recovery }
      tracker.register(type: :trust_violation, severity: :minor)
      20.times { tracker.tick_recovery }
      tracker.register(type: :system_error, severity: :minor)
      20.times { tracker.tick_recovery }

      model.update_from_tracker(tracker)
      expect(model.growth_bonus).to be > 0.0
    end

    it 'caps at MAX_GROWTH_BONUS' do
      max = Legion::Extensions::Agentic::Affect::Resilience::Helpers::Constants::MAX_GROWTH_BONUS
      # Force many consecutive recoveries
      20.times do
        tracker.register(type: :prediction_failure, severity: :minor)
        20.times { tracker.tick_recovery }
        model.update_from_tracker(tracker)
      end
      expect(model.growth_bonus).to be <= max
    end
  end

  describe 'history cap' do
    it 'caps at MAX_RESILIENCE_HISTORY' do
      max = Legion::Extensions::Agentic::Affect::Resilience::Helpers::Constants::MAX_RESILIENCE_HISTORY
      (max + 10).times { model.update_from_tracker(tracker) }
      expect(model.history.size).to eq(max)
    end
  end
end
