# frozen_string_literal: true

require 'legion/extensions/agentic/affect/emotion/client'

RSpec.describe Legion::Extensions::Agentic::Affect::Emotion::Runners::Valence do
  let(:client) { Legion::Extensions::Agentic::Affect::Emotion::Client.new }

  describe '#evaluate_partner_absence' do
    it 'returns a valence with all four dimensions' do
      result = client.evaluate_partner_absence(consecutive_misses: 1)
      expect(result[:valence].keys).to contain_exactly(:urgency, :importance, :novelty, :familiarity)
    end

    it 'sets urgency to 0.2' do
      result = client.evaluate_partner_absence(consecutive_misses: 1)
      expect(result[:valence][:urgency]).to eq(0.2)
    end

    it 'sets novelty to 0.1' do
      result = client.evaluate_partner_absence(consecutive_misses: 1)
      expect(result[:valence][:novelty]).to eq(0.1)
    end

    it 'sets familiarity to 0.8' do
      result = client.evaluate_partner_absence(consecutive_misses: 1)
      expect(result[:valence][:familiarity]).to eq(0.8)
    end

    it 'tags the event as :partner_absence' do
      result = client.evaluate_partner_absence(consecutive_misses: 1)
      expect(result[:event]).to eq(:partner_absence)
    end

    it 'includes consecutive_misses in the result' do
      result = client.evaluate_partner_absence(consecutive_misses: 5)
      expect(result[:consecutive_misses]).to eq(5)
    end

    it 'returns magnitude and dominant dimension' do
      result = client.evaluate_partner_absence(consecutive_misses: 1)
      expect(result[:magnitude]).to be > 0.0
      expect(result[:dominant_dimension]).to be_a(Symbol)
    end

    it 'increases importance with consecutive misses' do
      low = client.evaluate_partner_absence(consecutive_misses: 1)
      high = client.evaluate_partner_absence(consecutive_misses: 50)
      expect(high[:valence][:importance]).to be > low[:valence][:importance]
    end

    it 'caps importance at ABSENCE_MAX_IMPORTANCE' do
      helpers = Legion::Extensions::Agentic::Affect::Emotion::Helpers::Valence
      result = client.evaluate_partner_absence(consecutive_misses: 10_000)
      expect(result[:valence][:importance]).to eq(helpers::ABSENCE_MAX_IMPORTANCE)
    end

    it 'defaults to 1 consecutive miss' do
      result = client.evaluate_partner_absence
      expect(result[:consecutive_misses]).to eq(1)
    end
  end
end
