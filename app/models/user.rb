class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :birthdate, presence: true
  validates :api_token, uniqueness: true
  validates :api_token, presence: { if: :persisted? }
  validates :country, presence: true
  validates :total_points, presence: true, numericality: { greater_than_or_equal_to: 0 }

  has_many :transactions, dependent: :destroy
  has_many :user_rewards, dependent: :destroy
  has_many :rewards, through: :user_rewards

  before_validation :generate_api_token, on: :create

  private

    def generate_api_token
      self.api_token ||= SecureRandom.hex(20)
    end
end
