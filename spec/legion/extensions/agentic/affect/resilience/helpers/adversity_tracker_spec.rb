# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Agentic::Affect::Resilience::Helpers::AdversityTracker do
  subject(:tracker) { described_class.new }

  describe '#initialize' do
    it 'starts with no active adversities' do
      expect(tracker.active_adversities).to be_empty
    end

    it 'starts with no resolved adversities' do
      expect(tracker.resolved_adversities).to be_empty
    end

    it 'starts with zero consecutive recoveries' do
      expect(tracker.consecutive_recoveries).to eq(0)
    end
  end

  describe '#register' do
    it 'registers a valid adversity' do
      adversity = tracker.register(type: :prediction_failure, severity: :moderate)
      expect(adversity).to include(:id, :type, :severity, :impact, :phase, :current_health)
    end

    it 'adds to active adversities' do
      tracker.register(type: :trust_violation, severity: :major)
      expect(tracker.active_adversities.size).to eq(1)
    end

    it 'rejects unknown adversity type' do
      result = tracker.register(type: :unknown, severity: :minor)
      expect(result).to be_nil
    end

    it 'rejects unknown severity' do
      result = tracker.register(type: :prediction_failure, severity: :unknown)
      expect(result).to be_nil
    end

    it 'sets initial health based on impact' do
      adversity = tracker.register(type: :prediction_failure, severity: :major)
      expect(adversity[:current_health]).to eq(0.5)
    end

    it 'starts in absorbing phase' do
      adversity = tracker.register(type: :prediction_failure, severity: :minor)
      expect(adversity[:phase]).to eq(:absorbing)
    end

    it 'assigns sequential IDs' do
      a1 = tracker.register(type: :prediction_failure, severity: :minor)
      a2 = tracker.register(type: :trust_violation, severity: :moderate)
      expect(a2[:id]).to eq(a1[:id] + 1)
    end

    it 'accepts optional context' do
      adversity = tracker.register(type: :system_error, severity: :minor, context: { detail: 'timeout' })
      expect(adversity[:context][:detail]).to eq('timeout')
    end

    it 'caps active adversities' do
      max = Legion::Extensions::Agentic::Affect::Resilience::Helpers::Constants::MAX_ACTIVE_ADVERSITIES
      (max + 5).times { tracker.register(type: :prediction_failure, severity: :minor) }
      expect(tracker.active_adversities.size).to eq(max)
    end
  end

  describe '#tick_recovery' do
    before do
      tracker.register(type: :prediction_failure, severity: :moderate)
    end

    it 'returns recovery status' do
      result = tracker.tick_recovery
      expect(result).to include(:active_count, :resolved_count, :worst_health)
    end

    it 'increments ticks elapsed' do
      tracker.tick_recovery
      expect(tracker.active_adversities.first[:ticks_elapsed]).to eq(1)
    end

    it 'improves health over time' do
      initial = tracker.active_adversities.first[:current_health]
      tracker.tick_recovery
      expect(tracker.active_adversities.first[:current_health]).to be > initial
    end

    it 'resolves adversity when health reaches threshold' do
      recovery_ticks = Legion::Extensions::Agentic::Affect::Resilience::Helpers::Constants::SEVERITY_LEVELS[:moderate][:recovery_ticks]
      (recovery_ticks + 5).times { tracker.tick_recovery }
      expect(tracker.active_adversities).to be_empty
      expect(tracker.resolved_adversities.size).to eq(1)
    end

    it 'increments consecutive recoveries on resolution' do
      30.times { tracker.tick_recovery }
      expect(tracker.consecutive_recoveries).to be >= 1
    end

    it 'advances phases during recovery' do
      3.times { tracker.tick_recovery }
      phase = tracker.active_adversities.first&.fetch(:phase, nil)
      expect(phase).not_to be_nil
    end
  end

  describe '#worst_health' do
    it 'returns 1.0 with no adversities' do
      expect(tracker.worst_health).to eq(1.0)
    end

    it 'returns lowest health among active' do
      tracker.register(type: :prediction_failure, severity: :minor)
      tracker.register(type: :trust_violation, severity: :critical)
      expect(tracker.worst_health).to be < 0.1
    end
  end

  describe '#active_by_type' do
    it 'groups active adversities by type' do
      tracker.register(type: :prediction_failure, severity: :minor)
      tracker.register(type: :prediction_failure, severity: :moderate)
      tracker.register(type: :trust_violation, severity: :minor)
      result = tracker.active_by_type
      expect(result[:prediction_failure]).to eq(2)
      expect(result[:trust_violation]).to eq(1)
    end
  end

  describe '#recovery_rate' do
    it 'returns 0.0 with no resolved adversities' do
      expect(tracker.recovery_rate).to eq(0.0)
    end

    it 'returns rate of on-time recoveries' do
      tracker.register(type: :prediction_failure, severity: :minor)
      20.times { tracker.tick_recovery }
      expect(tracker.recovery_rate).to be > 0.0
    end
  end

  describe '#average_recovery_speed' do
    it 'returns 0.0 with no resolved adversities' do
      expect(tracker.average_recovery_speed).to eq(0.0)
    end

    it 'returns ratio of actual to expected ticks' do
      tracker.register(type: :prediction_failure, severity: :minor)
      20.times { tracker.tick_recovery }
      expect(tracker.average_recovery_speed).to be > 0.0
    end
  end

  describe '#total_adversities' do
    it 'counts active plus resolved' do
      tracker.register(type: :prediction_failure, severity: :minor)
      expect(tracker.total_adversities).to eq(1)
    end
  end
end
