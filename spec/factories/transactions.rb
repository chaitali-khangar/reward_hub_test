FactoryBot.define do
  factory :transaction do
    association :user
    amount { Faker::Commerce.price(range: 1.0..1000.0, as_string: false) }
    country { Faker::Address.country }
    external_id { SecureRandom.hex(10) }
  end
end
