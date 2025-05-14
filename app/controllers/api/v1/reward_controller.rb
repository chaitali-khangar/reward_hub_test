module Api
  module V1
    class RewardController < BaseController
      def available
        @rewards = @user.rewards.where(points_req: ..@user.total_points)
        render :available, status: :ok
      end

      def claim
        reward = Reward.find_by(id: params[:id])
        if reward.nil?
          render json: { 'error' => 'Reward not found' }, status: :not_found
          return
        end

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
