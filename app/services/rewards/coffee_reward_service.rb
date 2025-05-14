module Rewards
  class CoffeeRewardService
    attr_reader :user

    def initialize(user:, start_date:, end_date:, check_reward_already_granted:)
      @user = user
      @start_date = start_date
      @end_date = end_date
      @check_reward_already_granted = check_reward_already_granted
    end

    def call
      return { success: false, message: 'User not found' } unless user
      return { success: false, message: 'Reward not found' } unless coffee_reward

      return claim_reward if !@check_reward_already_granted || eligible_for_coffee_reward?

      { success: true, message: 'Reward already granted' }
    end

    private

      def eligible_for_coffee_reward?
        !reward_already_granted?
      end

      def reward_already_granted?
        user.user_rewards
            .where(reward: coffee_reward)
            .exists?(created_at: @start_date..@end_date)
      end

      def claim_reward
        result = Rewards::ClaimService.new(user, coffee_reward).call
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
