module Rewards
  class CoffeeRewardService
    def initialize(user, start_date, end_date)
      @user = user
      @start_date = start_date
      @end_date = end_date
    end

    def call
      return { success: false, message: 'User not found' } unless @user
      return { success: false, message: 'Reward not found' } unless coffee_reward

      return { success: false, message: 'Points not sufficient' } if monthly_points <= 100
      return { success: false, message: 'Reward already granted' } if reward_already_granted?

      claim_reward
    end

    private

      def eligible_for_coffee_reward?
        # Right now harcorded but we can use coffee_reward.point_req
        monthly_points >= 100 && !reward_already_granted?
      end

      def monthly_points
        @user.transactions.total_points_in_period(@start_date, @end_date)
      end

      def reward_already_granted?
        @user.user_rewards
             .where(reward: coffee_reward)
             .exists?(created_at: @start_date..@end_date)
      end

      def claim_reward
        result = Rewards::ClaimService.new(@user, coffee_reward).call
        if result[:success]
          { success: true, message: 'Free Coffee reward claimed successfully' }
        else
          { success: false, message: result[:message] }
        end
      end

      def coffee_reward
        # In future we can have reward_type which we can used to get coffee reward
        @coffee_reward ||= Reward.active.where(name: 'Free Coffee', points_req: 100).first
      end
  end
end
