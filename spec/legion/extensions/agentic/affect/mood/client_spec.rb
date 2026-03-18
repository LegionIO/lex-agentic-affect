# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Mood::Client do
  it 'creates default mood state' do
    client = described_class.new
    expect(client.mood_state).to be_a(Legion::Extensions::Agentic::Affect::Mood::Helpers::MoodState)
  end

  it 'accepts injected mood state' do
    state = Legion::Extensions::Agentic::Affect::Mood::Helpers::MoodState.new
    client = described_class.new(mood_state: state)
    expect(client.mood_state).to equal(state)
  end

  it 'includes Mood runner methods' do
    client = described_class.new
    expect(client).to respond_to(:update_mood, :current_mood, :mood_modulation,
                                 :mood_history, :mood_stats)
  end
end
