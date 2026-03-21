# frozen_string_literal: true

require 'legion/extensions/agentic/affect/emotion/client'

RSpec.describe Legion::Extensions::Agentic::Affect::Emotion::Runners::Valence do
  let(:client) { Legion::Extensions::Agentic::Affect::Emotion::Client.new }

  describe '#evaluate_valence' do
    it 'returns a valence with 4 dimensions' do
      result = client.evaluate_valence(signal: { urgency_hint: 0.5 })
      expect(result[:valence].keys).to contain_exactly(:urgency, :importance, :novelty, :familiarity)
    end

    it 'returns magnitude' do
      result = client.evaluate_valence(signal: {})
      expect(result[:magnitude]).to be >= 0.0
    end

    it 'returns dominant dimension' do
      result = client.evaluate_valence(signal: { domain_weight: 0.9, impact_scope: 0.8, outcome_severity: 0.9 })
      expect(result[:dominant_dimension]).to be_a(Symbol)
    end

    it 'responds to source type urgency' do
      ambient = client.evaluate_valence(signal: {}, source_type: :ambient)
      human = client.evaluate_valence(signal: {}, source_type: :human_direct)
      expect(human[:valence][:urgency]).to be >= ambient[:valence][:urgency]
    end

    it 'responds to deadlines' do
      no_deadline = client.evaluate_valence(signal: {})
      with_deadline = client.evaluate_valence(signal: {}, deadline: Time.now.utc + 60)
      expect(with_deadline[:valence][:urgency]).to be >= no_deadline[:valence][:urgency]
    end
  end

  describe '#aggregate_valences' do
    it 'aggregates multiple valences' do
      v = Legion::Extensions::Agentic::Affect::Emotion::Helpers::Valence
      valences = [
        v.new_valence(urgency: 0.8, importance: 0.2),
        v.new_valence(urgency: 0.4, importance: 0.6)
      ]
      result = client.aggregate_valences(valences: valences)
      expect(result[:aggregate][:urgency]).to be_within(0.01).of(0.6)
      expect(result[:count]).to eq(2)
    end
  end

  describe '#modulate_attention' do
    it 'boosts salience' do
      v = Legion::Extensions::Agentic::Affect::Emotion::Helpers::Valence.new_valence(urgency: 0.8, importance: 0.7)
      result = client.modulate_attention(base_salience: 0.5, valence: v)
      expect(result[:modulated]).to be > result[:original]
      expect(result[:boost]).to be > 0
    end
  end

  describe '#compute_arousal' do
    it 'computes arousal from valences' do
      v = Legion::Extensions::Agentic::Affect::Emotion::Helpers::Valence
      valences = [v.new_valence(urgency: 0.9, importance: 0.9)]
      result = client.compute_arousal(valences: valences)
      expect(result[:arousal]).to be > 0.0
    end
  end

  describe '#raise_urgency_for_knowledge_vulnerability' do
    it 'returns a valence result with event tag' do
      result = client.raise_urgency_for_knowledge_vulnerability(domains_at_risk: %w[pki vault])
      expect(result[:event]).to eq(:knowledge_vulnerability)
      expect(result[:domains_at_risk]).to eq(%w[pki vault])
    end

    it 'includes urgency_boost in the result' do
      result = client.raise_urgency_for_knowledge_vulnerability(domains_at_risk: ['pki'])
      expect(result[:urgency_boost]).to be > 0.0
    end

    it 'raises urgency higher for critical severity than warning' do
      warning = client.raise_urgency_for_knowledge_vulnerability(
        domains_at_risk: ['pki'], severity: :warning
      )
      critical = client.raise_urgency_for_knowledge_vulnerability(
        domains_at_risk: ['pki'], severity: :critical
      )
      expect(critical[:urgency_boost]).to be > warning[:urgency_boost]
    end

    it 'returns a valence hash with all four dimensions' do
      result = client.raise_urgency_for_knowledge_vulnerability(domains_at_risk: ['dns'])
      expect(result[:valence].keys).to contain_exactly(:urgency, :importance, :novelty, :familiarity)
    end

    it 'accepts a custom urgency_boost' do
      result = client.raise_urgency_for_knowledge_vulnerability(
        domains_at_risk: ['ssh'], urgency_boost: 0.5
      )
      expect(result[:urgency_boost]).to be_within(0.01).of(0.5)
    end
  end
end
