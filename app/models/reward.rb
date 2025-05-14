class Reward < ApplicationRecord
  validates :name, presence: true
  validates :points_req, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :valid_from, presence: true
  validates :valid_until, presence: true
  validate :valid_until_after_valid_from

  has_many :user_rewards, dependent: :destroy
  has_many :users, through: :user_rewards

  scope :active, -> { where(valid_until: DateTime.now..) }

  private

    def valid_until_after_valid_from
      return unless valid_from && valid_until && valid_until < valid_from

      errors.add(:valid_until, 'must be after valid_from')
    end
end
