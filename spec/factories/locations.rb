FactoryBot.define do
  factory :location do
    latitude { 35.6762 }
    longitude { 139.6503 }
    association :user
  end
end
