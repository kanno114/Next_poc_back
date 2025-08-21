FactoryBot.define do
  factory :weather_observation do
    temperature_c { 25.0 }
    humidity_pct { 60 }
    pressure_hpa { 1013.0 }
    observed_at { Time.current }
    snapshot { { visibility: 15, wind_speed: 13, weather_condition: '晴れ' } }
    association :daily_log
  end
end
