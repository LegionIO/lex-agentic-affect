# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Agentic::Affect::Resilience::Helpers::Constants do
  describe 'ADVERSITY_TYPES' do
    it 'defines 8 types' do
      expect(described_class::ADVERSITY_TYPES.size).to eq(8)
    end

    it 'includes prediction failure' do
      expect(described_class::ADVERSITY_TYPES).to include(:prediction_failure)
    end

    it 'includes trust violation' do
      expect(described_class::ADVERSITY_TYPES).to include(:trust_violation)
    end

    it 'is frozen' do
      expect(described_class::ADVERSITY_TYPES).to be_frozen
    end
  end

  describe 'RECOVERY_PHASES' do
    it 'defines 4 phases' do
      expect(described_class::RECOVERY_PHASES).to eq(%i[absorbing adapting recovering thriving])
    end
  end

  describe 'DIMENSIONS' do
    it 'defines 4 dimensions' do
      expect(described_class::DIMENSIONS.size).to eq(4)
    end

    it 'has weights summing to 1.0' do
      total = described_class::DIMENSIONS.values.sum { |v| v[:weight] }
      expect(total).to be_within(0.001).of(1.0)
    end

    it 'includes elasticity, robustness, adaptability, growth' do
      expect(described_class::DIMENSIONS.keys).to contain_exactly(:elasticity, :robustness, :adaptability, :growth)
    end
  end

  describe 'SEVERITY_LEVELS' do
    it 'defines 5 levels' do
      expect(described_class::SEVERITY_LEVELS.size).to eq(5)
    end

    it 'has increasing impact' do
      impacts = described_class::SEVERITY_LEVELS.values.map { |v| v[:impact] }
      expect(impacts).to eq(impacts.sort)
    end

    it 'has increasing recovery ticks' do
      ticks = described_class::SEVERITY_LEVELS.values.map { |v| v[:recovery_ticks] }
      expect(ticks).to eq(ticks.sort)
    end
  end

  describe 'thresholds' do
    it 'defines fragility threshold' do
      expect(described_class::FRAGILITY_THRESHOLD).to eq(0.3)
    end

    it 'defines antifragility threshold' do
      expect(described_class::ANTIFRAGILITY_THRESHOLD).to eq(0.7)
    end

    it 'defines recovery threshold' do
      expect(described_class::RECOVERY_THRESHOLD).to eq(0.9)
    end

    it 'defines growth trigger' do
      expect(described_class::GROWTH_TRIGGER).to eq(3)
    end
  end
end
