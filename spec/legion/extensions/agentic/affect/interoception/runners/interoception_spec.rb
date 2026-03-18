# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Interoception::Runners::Interoception do
  let(:client) { Legion::Extensions::Agentic::Affect::Interoception::Client.new }

  describe '#report_vital' do
    it 'reports and smooths a vital signal' do
      result = client.report_vital(channel: :cpu_load, value: 0.6)
      expect(result[:success]).to be true
      expect(result[:channel]).to eq(:cpu_load)
      expect(result[:smoothed]).to be_a(Float)
      expect(result).to have_key(:deviation)
      expect(result).to have_key(:label)
    end

    it 'tracks deviation from baseline' do
      5.times { client.report_vital(channel: :cpu_load, value: 0.2) }
      result = client.report_vital(channel: :cpu_load, value: 0.9)
      expect(result[:deviation].abs).to be > 0
    end
  end

  describe '#create_somatic_marker' do
    it 'creates a marker with correct fields' do
      result = client.create_somatic_marker(action: :deploy, domain: :prod, valence: 0.7)
      expect(result[:success]).to be true
      expect(result[:marker][:action]).to eq(:deploy)
      expect(result[:marker][:valence]).to eq(0.7)
      expect(result[:marker][:label]).to eq(:approach)
    end

    it 'creates negative marker' do
      result = client.create_somatic_marker(action: :delete_data, domain: :prod, valence: -0.8)
      expect(result[:marker][:label]).to eq(:avoid)
    end
  end

  describe '#query_bias' do
    it 'returns neutral with no markers' do
      result = client.query_bias(action: :deploy)
      expect(result[:success]).to be true
      expect(result[:bias]).to eq(0.0)
      expect(result[:label]).to eq(:neutral)
    end

    it 'returns approach bias for positive markers' do
      client.create_somatic_marker(action: :deploy, domain: :prod, valence: 0.8)
      result = client.query_bias(action: :deploy)
      expect(result[:bias]).to be > 0
    end

    it 'returns avoid bias for negative markers' do
      client.create_somatic_marker(action: :risky_change, domain: :prod, valence: -0.9)
      result = client.query_bias(action: :risky_change)
      expect(result[:bias]).to be < 0
    end
  end

  describe '#reinforce_somatic' do
    it 'reinforces matching markers' do
      client.create_somatic_marker(action: :deploy, domain: :prod, valence: 0.5, strength: 0.3)
      result = client.reinforce_somatic(action: :deploy, amount: 0.2)
      expect(result[:success]).to be true
    end
  end

  describe '#deviating_vitals' do
    it 'returns deviating channels' do
      result = client.deviating_vitals
      expect(result[:success]).to be true
      expect(result[:deviations]).to be_an(Array)
    end
  end

  describe '#body_status' do
    it 'returns overall health status' do
      client.report_vital(channel: :cpu_load, value: 0.2)
      result = client.body_status
      expect(result[:success]).to be true
      expect(result[:health]).to be_a(Float)
      expect(result).to have_key(:label)
      expect(result).to have_key(:channels)
      expect(result).to have_key(:markers)
    end
  end

  describe '#update_interoception' do
    it 'decays markers and returns status' do
      client.create_somatic_marker(action: :deploy, domain: :prod, valence: 0.5)
      result = client.update_interoception
      expect(result[:success]).to be true
      expect(result).to have_key(:health)
      expect(result).to have_key(:label)
      expect(result).to have_key(:channels)
      expect(result).to have_key(:markers)
    end
  end

  describe '#interoception_stats' do
    it 'returns comprehensive stats' do
      client.report_vital(channel: :cpu_load, value: 0.4)
      client.create_somatic_marker(action: :deploy, domain: :prod, valence: 0.7)
      result = client.interoception_stats
      expect(result[:success]).to be true
      expect(result[:stats]).to include(:overall_health, :body_budget_label, :channels, :markers)
    end
  end
end
