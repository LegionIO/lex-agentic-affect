# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Mood::Helpers::MoodState do
  subject(:state) { described_class.new }

  describe '#initialize' do
    it 'starts neutral' do
      expect(state.current_mood).to eq(:neutral)
    end

    it 'starts with moderate values' do
      expect(state.valence).to eq(0.5)
      expect(state.arousal).to eq(0.3)
      expect(state.energy).to eq(0.5)
    end
  end

  describe '#update' do
    it 'does not change mood before update interval' do
      state.update(valence: 0.9, arousal: 0.1)
      expect(state.tick_counter).to eq(1)
      expect(state.history).to be_empty
    end

    it 'updates mood at update interval' do
      Legion::Extensions::Agentic::Affect::Mood::Helpers::Constants::UPDATE_INTERVAL.times do
        state.update(valence: 0.8, arousal: 0.2, energy: 0.7)
      end
      expect(state.history.size).to eq(1)
    end

    it 'gradually shifts dimensions via EMA' do
      original_valence = state.valence
      Legion::Extensions::Agentic::Affect::Mood::Helpers::Constants::UPDATE_INTERVAL.times do
        state.update(valence: 0.9, arousal: 0.5, energy: 0.6)
      end
      expect(state.valence).to be > original_valence
    end

    it 'can reach serene mood with high valence and low arousal' do
      20.times do
        Legion::Extensions::Agentic::Affect::Mood::Helpers::Constants::UPDATE_INTERVAL.times do
          state.update(valence: 0.9, arousal: 0.1, energy: 0.8)
        end
      end
      expect(state.current_mood).to eq(:serene)
    end

    it 'can reach anxious mood with low valence and high arousal' do
      20.times do
        Legion::Extensions::Agentic::Affect::Mood::Helpers::Constants::UPDATE_INTERVAL.times do
          state.update(valence: 0.1, arousal: 0.9, energy: 0.5)
        end
      end
      expect(state.current_mood).to eq(:anxious)
    end
  end

  describe '#modulations' do
    it 'returns modulation hash for current mood' do
      mods = state.modulations
      expect(mods).to have_key(:attention_threshold)
      expect(mods).to have_key(:risk_tolerance)
      expect(mods).to have_key(:curiosity_boost)
    end
  end

  describe '#inertia' do
    it 'returns inertia value for current mood' do
      expect(state.inertia).to be_a(Numeric)
      expect(state.inertia).to be_between(0.0, 1.0)
    end
  end

  describe '#duration_in_current_mood' do
    it 'returns 0 with no history' do
      expect(state.duration_in_current_mood).to eq(0)
    end
  end

  describe '#mood_trend' do
    it 'returns :insufficient_data with few entries' do
      expect(state.mood_trend).to eq(:insufficient_data)
    end
  end

  describe '#to_h' do
    it 'returns complete state hash' do
      h = state.to_h
      expect(h).to include(:current_mood, :valence, :arousal, :energy,
                           :stability, :modulations, :inertia, :trend)
    end
  end
end
