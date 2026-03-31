# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Mood::Helpers::MoodState do
  subject(:state) { described_class.new }

  describe '#dirty?' do
    it 'is false on a fresh state' do
      expect(state.dirty?).to be false
    end

    it 'is true after an update that crosses the update interval' do
      Legion::Extensions::Agentic::Affect::Mood::Helpers::Constants::UPDATE_INTERVAL.times do
        state.update(valence: 0.8, arousal: 0.2, energy: 0.7)
      end
      expect(state.dirty?).to be true
    end
  end

  describe '#mark_clean!' do
    it 'resets dirty flag' do
      Legion::Extensions::Agentic::Affect::Mood::Helpers::Constants::UPDATE_INTERVAL.times do
        state.update(valence: 0.8, arousal: 0.2, energy: 0.7)
      end
      state.mark_clean!
      expect(state.dirty?).to be false
    end
  end

  describe '#to_apollo_entries' do
    it 'returns an array with a single entry' do
      entries = state.to_apollo_entries
      expect(entries).to be_an(Array)
      expect(entries.size).to eq(1)
    end

    it 'tags the entry with affect, state, and global' do
      entry = state.to_apollo_entries.first
      expect(entry[:tags]).to include('affect', 'state', 'global')
    end

    it 'serializes mood, valence, and arousal in content' do
      entry = state.to_apollo_entries.first
      parsed = JSON.parse(entry[:content])
      expect(parsed).to have_key('current_mood')
      expect(parsed).to have_key('valence')
      expect(parsed).to have_key('arousal')
      expect(parsed).to have_key('energy')
    end
  end

  describe '#from_apollo' do
    it 'restores valence, arousal, and energy from stored entry' do
      # Drive state to a non-default value
      20.times do
        Legion::Extensions::Agentic::Affect::Mood::Helpers::Constants::UPDATE_INTERVAL.times do
          state.update(valence: 0.9, arousal: 0.8, energy: 0.7)
        end
      end
      entries = state.to_apollo_entries

      new_state = described_class.new
      apollo_stub = double('apollo_local')
      allow(apollo_stub).to receive(:query).and_return(entries.map { |e| { content: e[:content] } })

      new_state.from_apollo(store: apollo_stub)
      expect(new_state.valence).to be_within(0.1).of(state.valence)
    end

    it 'handles empty apollo result gracefully' do
      apollo_stub = double('apollo_local')
      allow(apollo_stub).to receive(:query).and_return([])
      expect { state.from_apollo(store: apollo_stub) }.not_to raise_error
    end

    it 'handles invalid JSON gracefully' do
      apollo_stub = double('apollo_local')
      allow(apollo_stub).to receive(:query).and_return([{ content: 'bad_json{' }])
      expect { state.from_apollo(store: apollo_stub) }.not_to raise_error
    end
  end
end
