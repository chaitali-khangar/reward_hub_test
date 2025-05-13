class UserReward < ApplicationRecord
  belongs_to :user
  belongs_to :reward

  validates :status, presence: true, inclusion: { in: %w[Issued Redeemed], message: '%<value>s is not a valid status' }

  validate :redeemed_at_presence

  private

    def redeemed_at_presence
      return unless status == 'Redeemed' && redeemed_at.nil?

      errors.add(:redeemed_at, "must be present when status is 'Redeemed'")
    end
end
