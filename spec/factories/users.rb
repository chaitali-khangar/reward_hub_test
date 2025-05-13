FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    birthdate { Faker::Date.birthday(min_age: 18, max_age: 65) }
    api_token { SecureRandom.hex(20) }
    country { Faker::Address.country }
    total_points { 0 }
  end
end
