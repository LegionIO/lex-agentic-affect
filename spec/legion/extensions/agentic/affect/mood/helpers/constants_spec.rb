# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Mood::Helpers::Constants do
  it 'defines 9 mood states' do
    expect(described_class::MOOD_STATES.size).to eq(9)
  end

  it 'defines 4 dimensions' do
    expect(described_class::DIMENSIONS).to contain_exactly(:valence, :arousal, :energy, :stability)
  end

  it 'defines modulations for every mood state' do
    described_class::MOOD_STATES.each do |mood|
      expect(described_class::MOOD_MODULATIONS).to have_key(mood)
    end
  end

  it 'defines inertia for every mood state' do
    described_class::MOOD_STATES.each do |mood|
      expect(described_class::MOOD_INERTIA).to have_key(mood)
    end
  end

  it 'has inertia values between 0 and 1' do
    described_class::MOOD_INERTIA.each_value do |v|
      expect(v).to be_between(0.0, 1.0)
    end
  end
end
