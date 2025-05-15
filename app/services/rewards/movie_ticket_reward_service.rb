module Rewards
  class MovieTicketRewardService < BaseService
    attr_reader :user

    def initialize(user:)
      @user = user
      @reward = reward
    end

    def call
      return error_response('User not found') unless user
      return error_response('Reward not found') unless reward
      return error_response('Reward already granted') unless reward_claimed?

      claim_movie_ticket
    end

    private

      def reward_claimed?
        !user.user_rewards.exists?(reward: reward)
      end

      def claim_movie_ticket
        result = Rewards::ClaimService.new(user, reward).call
        if result[:success]
          success_response('Movie Ticket granted successfully')
        else
          error_response(result[:message])
        end
      end

      def reward
        @reward ||= Reward.active.where(name: 'Free Movie Tickets').first
      end
  end
end
