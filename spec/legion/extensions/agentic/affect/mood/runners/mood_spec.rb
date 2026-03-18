# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Mood::Runners::Mood do
  let(:client) { Legion::Extensions::Agentic::Affect::Mood::Client.new }

  let(:tick_results) do
    {
      emotional_evaluation: { magnitude: 0.6, arousal: 0.4 },
      elapsed:              2.0,
      budget:               5.0
    }
  end

  describe '#update_mood' do
    it 'returns mood state' do
      result = client.update_mood(tick_results: tick_results)
      expect(result).to have_key(:mood)
      expect(result).to have_key(:modulations)
    end

    it 'handles empty tick results' do
      result = client.update_mood(tick_results: {})
      expect(result[:mood]).to be_a(Symbol)
    end

    it 'handles valence hash from emotion' do
      results = tick_results.merge(
        emotional_evaluation: {
          valence: { urgency: 0.2, importance: 0.6, novelty: 0.3, familiarity: 0.7 },
          arousal: 0.5
        }
      )
      result = client.update_mood(tick_results: results)
      expect(result[:mood]).to be_a(Symbol)
    end
  end

  describe '#current_mood' do
    it 'returns full mood state' do
      result = client.current_mood
      expect(result).to include(:current_mood, :valence, :arousal, :energy, :stability)
    end
  end

  describe '#mood_modulation' do
    it 'returns modulation for a parameter' do
      result = client.mood_modulation(parameter: :curiosity_boost)
      expect(result[:parameter]).to eq(:curiosity_boost)
      expect(result[:modulation]).to be_a(Numeric)
    end

    it 'returns 0.0 for unknown parameter' do
      result = client.mood_modulation(parameter: :nonexistent)
      expect(result[:modulation]).to eq(0.0)
    end
  end

  describe '#mood_history' do
    it 'returns empty history initially' do
      result = client.mood_history
      expect(result[:entries]).to be_empty
    end
  end

  describe '#mood_stats' do
    it 'returns stats summary' do
      result = client.mood_stats
      expect(result).to include(:current_mood, :stability, :trend, :ticks_processed)
    end
  end
end
