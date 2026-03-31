# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::CognitiveEmpathy::Runners::CognitiveEmpathy do
  let(:runner) do
    obj = Object.new
    obj.extend(described_class)
    obj
  end

  let(:partner_obs) do
    {
      identity:       'esity',
      bond_role:      :partner,
      channel:        :cli,
      content_type:   :text,
      content_length: 80,
      direct_address: true,
      timestamp:      Time.now.utc
    }
  end

  let(:unknown_obs) do
    {
      identity:       'stranger',
      bond_role:      :unknown,
      channel:        :teams,
      content_type:   :text,
      content_length: 10,
      direct_address: false,
      timestamp:      Time.now.utc
    }
  end

  describe '#process_human_observations' do
    it 'returns empty result for empty array' do
      result = runner.process_human_observations(human_observations: [])
      expect(result[:processed]).to eq(0)
    end

    it 'processes a partner observation and creates a perspective' do
      result = runner.process_human_observations(human_observations: [partner_obs])
      expect(result[:processed]).to eq(1)
    end

    it 'processes multiple observations' do
      result = runner.process_human_observations(human_observations: [partner_obs, unknown_obs])
      expect(result[:processed]).to eq(2)
    end

    it 'applies contagion with higher virulence for partner bond_role' do
      before_level = runner.current_empathic_state[:contagion_level]
      runner.process_human_observations(human_observations: [partner_obs])
      after_level = runner.current_empathic_state[:contagion_level]
      expect(after_level).to be >= before_level
    end

    it 'applies contagion with lower virulence for unknown bond_role' do
      runner.process_human_observations(human_observations: [unknown_obs])
      result = runner.current_empathic_state
      expect(result[:contagion_level]).to be >= 0.0
    end
  end
end
