module Rewards
  class ClaimService
    attr_reader :user, :reward

    def initialize(user, reward)
      @user = user
      @reward = reward
    end

    def call
      return  { success: false, message: 'User not found' } unless @user
      return  { success: false, message: 'Reward not found' } unless @reward

      return { success: false, message: 'Insufficient points' } if user.total_points < reward.points_req

      ActiveRecord::Base.transaction do
        user.update!(total_points: user.total_points - reward.points_req)
        UserReward.create!(user: user, reward: reward, status: 'claimed')
      end

      { success: true, message: 'Reward claimed successfully' }
    rescue StandardError => e
      { success: false, message: e.message }
    end
  end
end
