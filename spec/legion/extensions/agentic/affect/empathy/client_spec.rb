# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Empathy::Client do
  it 'creates default model store' do
    client = described_class.new
    expect(client.model_store).to be_a(Legion::Extensions::Agentic::Affect::Empathy::Helpers::ModelStore)
  end

  it 'accepts injected model store' do
    store = Legion::Extensions::Agentic::Affect::Empathy::Helpers::ModelStore.new
    client = described_class.new(model_store: store)
    expect(client.model_store).to equal(store)
  end

  it 'includes Empathy runner methods' do
    client = described_class.new
    expect(client).to respond_to(:observe_agent, :predict_reaction, :perspective_take,
                                 :social_landscape, :empathy_stats)
  end
end
