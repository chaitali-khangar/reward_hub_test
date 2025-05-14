class Transaction < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 10_000_000 }
  validates :country, presence: true
  validates :external_id, presence: true, uniqueness: true

  after_create :calculate_and_update_points

  def calculate_and_update_points
    earned_points = calculate_points
    user.update(total_points: user.total_points + earned_points)
  end

  def calculate_points
    base_points = (amount / 100).floor * 10

    # Apply foreign country multiplier
    country == user.country ? base_points : base_points * 2
  end
end
