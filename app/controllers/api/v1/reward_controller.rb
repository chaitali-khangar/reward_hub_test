module Api
  module V1
    class RewardController < BaseController
      def available
        @rewards = Reward.where(points_req: ..@user.total_points)
        render :available, status: :ok
      end

      def claimed
        @rewards = @user.claimed_rewards
        render :claimed, status: :ok
      end

      def claim
        reward = Reward.find(params[:id])
        result = Rewards::ClaimService.new(@user, reward).call

        if result[:success]
          render json: { 'message' => result[:message] }, status: :ok
        else
          render json: { 'error' => result[:message] }, status: :unprocessable_entity
        end
      end
    end
  end
end
