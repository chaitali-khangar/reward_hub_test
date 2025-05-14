FactoryBot.define do
  factory :user_reward do
    association :user
    association :reward
    status { 'claimed' }
    redeemed_at { nil }
  end
end
