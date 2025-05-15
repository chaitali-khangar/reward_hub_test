module Rewards
  class ClaimService < BaseService
    attr_reader :user, :reward

    def initialize(user, reward)
      @user = user
      @reward = reward
    end

    def call
      return error_response('User not found') unless user
      return error_response('Reward not found') unless reward

      return error_response('Insufficient points') unless sufficient_points?

      ActiveRecord::Base.transaction do
        user.update!(total_points: user.total_points - reward.points_req)
        UserReward.create!(user: user, reward: reward, status: 'claimed')
      end

      success_response('Reward claimed successfully')
    rescue StandardError => e
      error_response(e.message)
    end

    private

      def sufficient_points?
        user.total_points >= reward.points_req
      end
  end
end
