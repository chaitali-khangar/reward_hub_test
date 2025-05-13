FactoryBot.define do
  factory :reward do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }
    points_req { rand(100..1000) }
    valid_from { Faker::Time.backward(days: 30, period: :morning) }
    valid_until { Faker::Time.forward(days: 30, period: :evening) }
  end
end
