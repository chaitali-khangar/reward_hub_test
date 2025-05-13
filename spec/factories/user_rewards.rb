FactoryBot.define do
  factory :user_reward do
    association :user
    association :reward
    status { %w[Issued Redeemed].sample }
    redeemed_at { status == 'Redeemed' ? Faker::Time.backward(days: 7, period: :evening) : nil }
  end
end
