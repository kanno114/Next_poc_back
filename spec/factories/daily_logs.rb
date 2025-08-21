FactoryBot.define do
  factory :daily_log do
    date { Date.current }
    score { 80 }
    sleep_hours { 7.0 }
    mood { 2 }
    memo { '今日は良い天気でした' }
    association :user
  end
end
