10.times do |_i|
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    birthdate: Faker::Date.birthday(min_age: 18, max_age: 65),
    api_token: SecureRandom.hex(20),
    country: Faker::Address.country,
    total_points: rand(0..500)
  )
end

rewards = [
  {
    name: 'Free Coffee',
    description: 'Enjoy a free coffee for collecting 100 points.',
    points_req: 100,
    valid_from: Time.zone.today,
    valid_until: 1.year.from_now
  },
  {
    name: 'Free Movie Tickets',
    description: 'Get free movie tickets for new users spending more than $1000 within 60 days.',
    points_req: 1000,
    valid_from: Time.zone.today,
    valid_until: 1.year.from_now
  }
]

rewards.each do |reward_data|
  reward = Reward.find_or_initialize_by(name: reward_data[:name])
  reward.update!(reward_data)
end
