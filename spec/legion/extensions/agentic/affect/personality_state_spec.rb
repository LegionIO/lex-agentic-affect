# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::PersonalityState do
  subject(:ps) { described_class.new }

  describe '#initialize' do
    it 'starts with neutral OCEAN traits at 0.5' do
      expect(ps.openness).to eq(0.5)
      expect(ps.conscientiousness).to eq(0.5)
      expect(ps.extraversion).to eq(0.5)
      expect(ps.agreeableness).to eq(0.5)
      expect(ps.neuroticism).to eq(0.5)
    end

    it 'is not dirty initially' do
      expect(ps.dirty?).to be false
    end
  end

  describe '#update_trait' do
    it 'updates a single trait' do
      ps.update_trait(:openness, 0.8)
      expect(ps.openness).to be_within(0.01).of(0.8)
    end

    it 'marks dirty after a significant change' do
      ps.update_trait(:openness, 0.9)
      expect(ps.dirty?).to be true
    end

    it 'does not mark dirty for a tiny change below threshold' do
      ps.update_trait(:openness, 0.501)
      expect(ps.dirty?).to be false
    end

    it 'clamps values to [0.0, 1.0]' do
      ps.update_trait(:openness, 1.5)
      expect(ps.openness).to eq(1.0)
      ps.update_trait(:openness, -0.5)
      expect(ps.openness).to eq(0.0)
    end
  end

  describe '#mark_clean!' do
    it 'resets dirty flag' do
      ps.update_trait(:openness, 0.9)
      ps.mark_clean!
      expect(ps.dirty?).to be false
    end
  end

  describe '#to_apollo_entries' do
    it 'returns one entry' do
      entries = ps.to_apollo_entries
      expect(entries.size).to eq(1)
    end

    it 'tags the entry with personality, ocean, and global' do
      entry = ps.to_apollo_entries.first
      expect(entry[:tags]).to include('personality', 'ocean', 'global')
    end

    it 'serializes all 5 OCEAN traits in content' do
      entry = ps.to_apollo_entries.first
      parsed = JSON.parse(entry[:content])
      expect(parsed).to have_key('openness')
      expect(parsed).to have_key('conscientiousness')
      expect(parsed).to have_key('extraversion')
      expect(parsed).to have_key('agreeableness')
      expect(parsed).to have_key('neuroticism')
    end
  end

  describe '#from_apollo' do
    it 'restores OCEAN traits from stored entry' do
      ps.update_trait(:openness, 0.9)
      ps.update_trait(:neuroticism, 0.2)
      entries = ps.to_apollo_entries

      new_ps = described_class.new
      apollo_stub = double('apollo_local')
      allow(apollo_stub).to receive(:query).and_return(entries.map { |e| { content: e[:content] } })

      new_ps.from_apollo(store: apollo_stub)
      expect(new_ps.openness).to eq(0.9)
      expect(new_ps.neuroticism).to eq(0.2)
    end

    it 'handles empty apollo result gracefully' do
      apollo_stub = double('apollo_local')
      allow(apollo_stub).to receive(:query).and_return([])
      expect { ps.from_apollo(store: apollo_stub) }.not_to raise_error
    end

    it 'handles invalid JSON gracefully' do
      apollo_stub = double('apollo_local')
      allow(apollo_stub).to receive(:query).and_return([{ content: 'bad{json' }])
      expect { ps.from_apollo(store: apollo_stub) }.not_to raise_error
    end
  end

  describe '#to_h' do
    it 'returns hash of all 5 traits' do
      h = ps.to_h
      expect(h.keys).to include(:openness, :conscientiousness, :extraversion, :agreeableness, :neuroticism)
    end
  end
end
