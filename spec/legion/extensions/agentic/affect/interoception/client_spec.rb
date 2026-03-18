# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Affect::Interoception::Client do
  subject(:client) { described_class.new }

  it 'includes Runners::Interoception' do
    expect(described_class.ancestors).to include(Legion::Extensions::Agentic::Affect::Interoception::Runners::Interoception)
  end

  it 'responds to all runner methods' do
    expect(client).to respond_to(:report_vital)
    expect(client).to respond_to(:create_somatic_marker)
    expect(client).to respond_to(:query_bias)
    expect(client).to respond_to(:reinforce_somatic)
    expect(client).to respond_to(:deviating_vitals)
    expect(client).to respond_to(:body_status)
    expect(client).to respond_to(:update_interoception)
    expect(client).to respond_to(:interoception_stats)
  end

  it 'supports full somatic marker lifecycle' do
    # Report some vitals
    client.report_vital(channel: :cpu_load, value: 0.3)
    client.report_vital(channel: :connection_health, value: 0.9)

    # Create markers based on outcomes
    client.create_somatic_marker(action: :deploy, domain: :prod, valence: 0.8)
    client.create_somatic_marker(action: :risky_change, domain: :prod, valence: -0.6)

    # Query bias should reflect markers
    approach = client.query_bias(action: :deploy)
    expect(approach[:bias]).to be > 0

    avoid = client.query_bias(action: :risky_change)
    expect(avoid[:bias]).to be < 0

    # Reinforce good outcome
    client.reinforce_somatic(action: :deploy)

    # Tick decay
    client.update_interoception

    # Check overall status
    status = client.body_status
    expect(status[:success]).to be true
    expect(status[:health]).to be > 0

    stats = client.interoception_stats
    expect(stats[:stats][:channels]).to eq(2)
    expect(stats[:stats][:markers]).to be >= 1
  end
end
