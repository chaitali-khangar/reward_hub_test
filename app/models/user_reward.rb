class UserReward < ApplicationRecord
  belongs_to :user
  belongs_to :reward

  validates :status, presence: true

  validate :redeemed_at_presence

  enum status: %w[claimed redeemed expired].index_by(&:itself)

  private

    def redeemed_at_presence
      return unless status == 'redeemed' && redeemed_at.nil?

      errors.add(:redeemed_at, "must be present when status is 'redeemed'")
    end
end
