# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Interoception::Helpers::BodyBudget do
  subject(:budget) { described_class.new }

  describe '#report_vital' do
    it 'stores and smooths a vital signal' do
      result = budget.report_vital(channel: :cpu_load, value: 0.7)
      expect(result).to be_a(Float)
      expect(result).to be_between(0.0, 1.0)
    end

    it 'applies EMA smoothing on repeated reports' do
      budget.report_vital(channel: :cpu_load, value: 0.2)
      budget.report_vital(channel: :cpu_load, value: 0.8)
      val = budget.vital_for(:cpu_load)
      expect(val).to be_between(0.2, 0.8)
    end

    it 'clamps values to 0..1' do
      budget.report_vital(channel: :cpu_load, value: 5.0)
      expect(budget.vital_for(:cpu_load)).to be <= 1.0
    end

    it 'updates baseline over time' do
      10.times { budget.report_vital(channel: :cpu_load, value: 0.9) }
      expect(budget.baselines[:cpu_load]).to be > 0.5
    end
  end

  describe '#deviation_for' do
    it 'returns 0 for new channels' do
      expect(budget.deviation_for(:cpu_load)).to eq(0.0)
    end

    it 'detects deviation from baseline' do
      5.times { budget.report_vital(channel: :cpu_load, value: 0.3) }
      budget.report_vital(channel: :cpu_load, value: 0.9)
      expect(budget.deviation_for(:cpu_load).abs).to be > 0
    end
  end

  describe '#vital_label' do
    it 'returns :healthy for healthy vitals' do
      budget.report_vital(channel: :connection_health, value: 0.9)
      expect(budget.vital_label(:connection_health)).to eq(:healthy)
    end

    it 'returns :critical for bad inverted vitals' do
      budget.report_vital(channel: :cpu_load, value: 0.95)
      expect(budget.vital_label(:cpu_load)).to eq(:critical)
    end
  end

  describe '#vital_health' do
    it 'inverts cpu_load (high load = low health)' do
      budget.report_vital(channel: :cpu_load, value: 0.9)
      expect(budget.vital_health(:cpu_load)).to be < 0.2
    end

    it 'keeps connection_health direct (high = good)' do
      budget.report_vital(channel: :connection_health, value: 0.9)
      expect(budget.vital_health(:connection_health)).to be > 0.8
    end
  end

  describe '#deviating_channels' do
    it 'returns empty when no deviations' do
      expect(budget.deviating_channels).to be_empty
    end

    it 'detects channels with significant deviation' do
      5.times { budget.report_vital(channel: :cpu_load, value: 0.2) }
      # Force a big jump
      budget.report_vital(channel: :cpu_load, value: 0.95)
      budget.report_vital(channel: :cpu_load, value: 0.95)
      budget.report_vital(channel: :cpu_load, value: 0.95)
      deviations = budget.deviating_channels
      expect(deviations.first[:channel]).to eq(:cpu_load) if deviations.any?
    end
  end

  describe 'somatic markers' do
    describe '#create_marker' do
      it 'creates and stores a marker' do
        marker = budget.create_marker(action: :deploy, domain: :prod, valence: 0.7)
        expect(marker).to be_a(Legion::Extensions::Agentic::Affect::Interoception::Helpers::SomaticMarker)
        expect(budget.marker_count).to eq(1)
      end
    end

    describe '#markers_for' do
      it 'finds markers by action' do
        budget.create_marker(action: :deploy, domain: :prod, valence: 0.5)
        budget.create_marker(action: :deploy, domain: :staging, valence: 0.3)
        budget.create_marker(action: :rollback, domain: :prod, valence: -0.5)
        expect(budget.markers_for(action: :deploy).size).to eq(2)
      end

      it 'filters by domain' do
        budget.create_marker(action: :deploy, domain: :prod, valence: 0.5)
        budget.create_marker(action: :deploy, domain: :staging, valence: 0.3)
        expect(budget.markers_for(action: :deploy, domain: :prod).size).to eq(1)
      end
    end

    describe '#bias_for_action' do
      it 'returns 0.0 with no markers' do
        expect(budget.bias_for_action(action: :deploy)).to eq(0.0)
      end

      it 'returns positive bias for approach markers' do
        budget.create_marker(action: :deploy, domain: :prod, valence: 0.8)
        expect(budget.bias_for_action(action: :deploy)).to be > 0
      end

      it 'returns negative bias for avoid markers' do
        budget.create_marker(action: :deploy, domain: :prod, valence: -0.8)
        expect(budget.bias_for_action(action: :deploy)).to be < 0
      end
    end

    describe '#reinforce_markers' do
      it 'increases strength of matching markers' do
        budget.create_marker(action: :deploy, domain: :prod, valence: 0.5, strength: 0.4)
        budget.reinforce_markers(action: :deploy, amount: 0.2)
        marker = budget.markers_for(action: :deploy).first
        expect(marker.strength).to be_within(0.001).of(0.6)
      end
    end

    describe '#decay_markers' do
      it 'decays all markers' do
        budget.create_marker(action: :deploy, domain: :prod, valence: 0.5)
        before = budget.markers_for(action: :deploy).first.strength
        budget.decay_markers
        after = budget.markers_for(action: :deploy).first&.strength
        expect(after).to be < before if after
      end

      it 'prunes faded markers' do
        floor = Legion::Extensions::Agentic::Affect::Interoception::Helpers::Constants::MARKER_FLOOR
        budget.create_marker(action: :deploy, domain: :prod, valence: 0.5, strength: floor + 0.01)
        budget.decay_markers
        expect(budget.marker_count).to eq(0)
      end
    end
  end

  describe '#overall_health' do
    it 'returns DEFAULT_BASELINE with no vitals' do
      expect(budget.overall_health).to eq(Legion::Extensions::Agentic::Affect::Interoception::Helpers::Constants::DEFAULT_BASELINE)
    end

    it 'computes average health across channels' do
      budget.report_vital(channel: :connection_health, value: 0.9)
      budget.report_vital(channel: :cpu_load, value: 0.1) # low load = healthy
      expect(budget.overall_health).to be > 0.7
    end
  end

  describe '#body_budget_label' do
    it 'returns :comfortable for healthy vitals' do
      budget.report_vital(channel: :connection_health, value: 0.7)
      label = budget.body_budget_label
      expect(%i[thriving comfortable]).to include(label)
    end
  end

  describe '#to_h' do
    it 'returns comprehensive stats' do
      budget.report_vital(channel: :cpu_load, value: 0.3)
      budget.create_marker(action: :deploy, domain: :prod, valence: 0.5)
      h = budget.to_h
      expect(h).to include(:overall_health, :body_budget_label, :channels, :markers, :vitals, :deviations)
    end
  end
end
