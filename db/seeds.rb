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
