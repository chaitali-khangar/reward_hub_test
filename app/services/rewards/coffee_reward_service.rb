module Rewards
  class CoffeeRewardService < BaseService
    attr_reader :user

    def initialize(user:, start_date:, end_date:, check_reward_already_granted:)
      @user = user
      @start_date = start_date
      @end_date = end_date
      @check_reward_already_granted = check_reward_already_granted
    end

    def call
      return error_response('User not found') unless user
      return error_response('Reward not found') unless coffee_reward

      return claim_reward if check_reward_granting?

      error_response('Reward already granted')
    end

    private

      def check_reward_granting?
        !@check_reward_already_granted || !reward_claimed?
      end

      def reward_claimed?
        user.user_rewards
            .where(reward: coffee_reward)
            .exists?(created_at: @start_date..@end_date)
      end

      def claim_reward
        result = Rewards::ClaimService.new(user, coffee_reward).call
        if result[:success]
          success_response('Free Coffee reward claimed successfully')
        else
          error_response(result[:message])
        end
      end

      def coffee_reward
        # In future we can have reward_type which we can used to get coffee reward
        @coffee_reward ||= Reward.active.where(name: 'Free Coffee', points_req: 100).first
      end
  end
end
