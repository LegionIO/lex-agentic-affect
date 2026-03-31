# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Empathy::Runners::Empathy do
  let(:client) { Legion::Extensions::Agentic::Affect::Empathy::Client.new }

  let(:partner_obs) do
    {
      identity:       'esity',
      bond_role:      :partner,
      channel:        :cli,
      content_type:   :text,
      content_length: 50,
      direct_address: true,
      timestamp:      Time.now.utc
    }
  end

  let(:known_obs) do
    {
      identity:       'alice',
      bond_role:      :known,
      channel:        :teams,
      content_type:   :text,
      content_length: 20,
      direct_address: false,
      timestamp:      Time.now.utc
    }
  end

  describe '#observe_human_observations' do
    it 'returns empty result for empty array' do
      result = client.observe_human_observations(human_observations: [])
      expect(result[:observed]).to eq(0)
    end

    it 'processes a single partner observation' do
      result = client.observe_human_observations(human_observations: [partner_obs])
      expect(result[:observed]).to eq(1)
      expect(result[:identities]).to include('esity')
    end

    it 'processes multiple observations' do
      result = client.observe_human_observations(human_observations: [partner_obs, known_obs])
      expect(result[:observed]).to eq(2)
      expect(result[:identities]).to include('esity', 'alice')
    end

    it 'creates mental models for each identity' do
      client.observe_human_observations(human_observations: [partner_obs])
      model = client.model_store.get('esity')
      expect(model).not_to be_nil
    end

    it 'sets higher confidence for partner bond_role' do
      client.observe_human_observations(human_observations: [partner_obs])
      model = client.model_store.get('esity')
      expect(model.confidence_level).to be > 0.7
    end

    it 'marks store as dirty after observations' do
      client.observe_human_observations(human_observations: [partner_obs])
      expect(client.model_store.dirty?).to be true
    end
  end
end
