# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Agentic::Affect::Resilience::Runners::Resilience do
  let(:client) { Legion::Extensions::Agentic::Affect::Resilience::Client.new }

  let(:normal_tick) do
    {
      prediction_engine:    { error_rate: 0.2 },
      trust:                {},
      conflict:             {},
      fatigue:              { energy: 0.7 },
      emotional_evaluation: { arousal: 0.5 }
    }
  end

  let(:adverse_tick) do
    {
      prediction_engine:    { error_rate: 0.8 },
      trust:                { violation: true },
      conflict:             { severity: 4 },
      fatigue:              { energy: 0.1 },
      emotional_evaluation: { arousal: 0.95 }
    }
  end

  describe '#update_resilience' do
    it 'returns resilience status' do
      result = client.update_resilience(tick_results: normal_tick)
      expect(result).to include(:active_adversities, :resolved_this_tick, :worst_health,
                                :composite_score, :classification, :growth_bonus)
    end

    it 'detects no adversities in normal conditions' do
      result = client.update_resilience(tick_results: normal_tick)
      expect(result[:active_adversities]).to eq(0)
    end

    it 'detects multiple adversities in adverse conditions' do
      result = client.update_resilience(tick_results: adverse_tick)
      expect(result[:active_adversities]).to be > 0
    end

    it 'handles empty tick results' do
      result = client.update_resilience(tick_results: {})
      expect(result[:composite_score]).to be_a(Float)
    end
  end

  describe '#register_adversity' do
    it 'registers valid adversity' do
      result = client.register_adversity(type: :prediction_failure, severity: :moderate)
      expect(result[:success]).to be true
      expect(result[:adversity]).to include(:id, :type, :severity)
    end

    it 'rejects invalid adversity' do
      result = client.register_adversity(type: :unknown, severity: :minor)
      expect(result[:success]).to be false
    end
  end

  describe '#resilience_status' do
    it 'returns full status' do
      status = client.resilience_status
      expect(status).to include(:dimensions, :composite, :class, :trend,
                                :active_adversities, :total_adversities,
                                :consecutive_recoveries, :recovery_rate)
    end
  end

  describe '#adversity_report' do
    it 'returns adversity details' do
      report = client.adversity_report
      expect(report).to include(:active, :by_type, :total, :worst, :avg_speed)
    end

    it 'reports active adversities' do
      client.register_adversity(type: :prediction_failure, severity: :minor)
      report = client.adversity_report
      expect(report[:active].size).to eq(1)
    end
  end

  describe '#dimension_detail' do
    it 'returns detail for known dimension' do
      detail = client.dimension_detail(dimension: :elasticity)
      expect(detail).to include(:name, :value, :config, :trend, :healthy)
    end

    it 'returns error for unknown dimension' do
      detail = client.dimension_detail(dimension: :unknown)
      expect(detail).to have_key(:error)
    end
  end

  describe '#resilience_stats' do
    it 'returns comprehensive stats' do
      stats = client.resilience_stats
      expect(stats).to include(:composite, :classification, :dimensions,
                               :growth_bonus, :trend, :total_adversities,
                               :active_adversities, :recovery_rate,
                               :consecutive_recoveries, :history_size)
    end
  end

  describe 'adversity detection from tick results' do
    it 'detects high prediction error' do
      client.update_resilience(tick_results: { prediction_engine: { error_rate: 0.8 } })
      expect(client.adversity_tracker.active_adversities.size).to eq(1)
    end

    it 'detects trust violation' do
      client.update_resilience(tick_results: { trust: { violation: true } })
      expect(client.adversity_tracker.active_adversities.any? { |a| a[:type] == :trust_violation }).to be true
    end

    it 'detects conflict escalation' do
      client.update_resilience(tick_results: { conflict: { severity: 4 } })
      expect(client.adversity_tracker.active_adversities.any? { |a| a[:type] == :conflict_escalation }).to be true
    end

    it 'detects resource depletion' do
      client.update_resilience(tick_results: { fatigue: { energy: 0.05 } })
      expect(client.adversity_tracker.active_adversities.any? { |a| a[:type] == :resource_depletion }).to be true
    end

    it 'detects emotional shock' do
      client.update_resilience(tick_results: { emotional_evaluation: { arousal: 0.95 } })
      expect(client.adversity_tracker.active_adversities.any? { |a| a[:type] == :emotional_shock }).to be true
    end
  end

  describe 'recovery over time' do
    it 'resolves adversities after enough ticks' do
      client.register_adversity(type: :prediction_failure, severity: :minor)
      20.times { client.update_resilience(tick_results: normal_tick) }
      expect(client.adversity_tracker.active_adversities).to be_empty
    end

    it 'builds growth bonus from consecutive recoveries' do
      3.times do
        client.register_adversity(type: :prediction_failure, severity: :minor)
        20.times { client.update_resilience(tick_results: normal_tick) }
      end
      expect(client.resilience_model.growth_bonus).to be > 0.0
    end
  end
end
