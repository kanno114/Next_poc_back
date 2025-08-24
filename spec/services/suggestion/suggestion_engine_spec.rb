require "rails_helper"
require_relative "../../../app/services/suggestion/rule_registry"
require_relative "../../../app/services/suggestion/suggestion_engine"

RSpec.describe SuggestionEngine do
  let(:user) { create(:user) }
  let(:date) { Date.new(2025, 8, 21) }
  let(:daily_log) { create(:daily_log, user:, date:, sleep_hours: 7.0, mood: -2, score: 48) }

  before do
    daily_log # daily_logを作成
    create(:weather_observation, daily_log:, temperature_c: 35.0, humidity_pct: 85, pressure_hpa: 1013.0)
    RuleRegistry.reload!
  end

  it "returns up to 3 diverse suggestions by severity" do
    list = described_class.call(user:, date:)
    expect(list.size).to be <= 3
    expect(list.map(&:id)).to include("hot_weather", "high_humidity")
  end
end
