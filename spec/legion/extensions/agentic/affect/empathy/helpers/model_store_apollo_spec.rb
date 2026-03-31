# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Empathy::Helpers::ModelStore do
  subject(:store) { described_class.new }

  let(:obs_partner) do
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

  let(:obs_unknown) do
    {
      identity:       'stranger',
      bond_role:      :unknown,
      channel:        :teams,
      content_type:   :text,
      content_length: 20,
      direct_address: false,
      timestamp:      Time.now.utc
    }
  end

  describe '#update_from_human_observation' do
    it 'creates a model for the observed identity' do
      model = store.update_from_human_observation(obs_partner)
      expect(model.agent_id).to eq('esity')
    end

    it 'sets confidence to 0.8 for partner bond_role' do
      model = store.update_from_human_observation(obs_partner)
      expect(model.confidence_level).to be_within(0.05).of(0.8)
    end

    it 'sets confidence near 0.5 for unknown bond_role' do
      model = store.update_from_human_observation(obs_unknown)
      expect(model.confidence_level).to be_within(0.1).of(0.5)
    end

    it 'stores bond_role on the model' do
      model = store.update_from_human_observation(obs_partner)
      expect(model.bond_role).to eq(:partner)
    end

    it 'stores channel on the model' do
      model = store.update_from_human_observation(obs_partner)
      expect(model.channel).to eq(:cli)
    end

    it 'increments store size' do
      store.update_from_human_observation(obs_partner)
      store.update_from_human_observation(obs_unknown)
      expect(store.size).to eq(2)
    end
  end

  describe '#dirty?' do
    it 'is false on new store' do
      expect(store.dirty?).to be false
    end

    it 'is true after an update_from_human_observation' do
      store.update_from_human_observation(obs_partner)
      expect(store.dirty?).to be true
    end

    it 'is false after mark_clean!' do
      store.update_from_human_observation(obs_partner)
      store.mark_clean!
      expect(store.dirty?).to be false
    end
  end

  describe '#mark_clean!' do
    it 'resets dirty flag' do
      store.update_from_human_observation(obs_partner)
      store.mark_clean!
      expect(store.dirty?).to be false
    end
  end

  describe '#to_apollo_entries' do
    it 'returns empty array when store is empty' do
      expect(store.to_apollo_entries).to eq([])
    end

    it 'returns one entry per model' do
      store.update_from_human_observation(obs_partner)
      store.update_from_human_observation(obs_unknown)
      expect(store.to_apollo_entries.size).to eq(2)
    end

    it 'includes empathy, mental_model, and agent_id in tags' do
      store.update_from_human_observation(obs_partner)
      entry = store.to_apollo_entries.first
      expect(entry[:tags]).to include('empathy', 'mental_model', 'esity')
    end

    it 'serializes content as a JSON string' do
      store.update_from_human_observation(obs_partner)
      entry = store.to_apollo_entries.first
      parsed = JSON.parse(entry[:content])
      expect(parsed['agent_id']).to eq('esity')
      expect(parsed).to have_key('confidence_level')
    end
  end

  describe '#from_apollo' do
    it 'restores models from apollo entries' do
      store.update_from_human_observation(obs_partner)
      entries = store.to_apollo_entries

      new_store = described_class.new
      apollo_stub = double('apollo_local')
      allow(apollo_stub).to receive(:query).and_return(entries.map { |e| { content: e[:content] } })

      new_store.from_apollo(store: apollo_stub)
      expect(new_store.size).to eq(1)
      expect(new_store.get('esity')).not_to be_nil
    end

    it 'restores bond_role on loaded model' do
      store.update_from_human_observation(obs_partner)
      entries = store.to_apollo_entries

      new_store = described_class.new
      apollo_stub = double('apollo_local')
      allow(apollo_stub).to receive(:query).and_return(entries.map { |e| { content: e[:content] } })

      new_store.from_apollo(store: apollo_stub)
      expect(new_store.get('esity').bond_role).to eq(:partner)
    end

    it 'handles empty apollo result gracefully' do
      apollo_stub = double('apollo_local')
      allow(apollo_stub).to receive(:query).and_return([])
      expect { store.from_apollo(store: apollo_stub) }.not_to raise_error
      expect(store.size).to eq(0)
    end

    it 'skips entries with invalid JSON content' do
      apollo_stub = double('apollo_local')
      allow(apollo_stub).to receive(:query).and_return([{ content: 'not_json' }])
      expect { store.from_apollo(store: apollo_stub) }.not_to raise_error
    end
  end
end
