module Rewards
  class MovieTicketRewardService
    attr_reader :user

    def initialize(user:)
      @user = user
    end

    def call
      return { success: false, message: 'User not found' } unless user
      return { success: false, message: 'Reward not found' } unless movie_reward
      return { success: true, message: 'Reward already granted' } unless reward_claimed?

      claim_movie_ticket
    end

    private

      def reward_claimed?
        !user.user_rewards.exists?(reward: movie_reward)
      end

      def claim_movie_ticket
        result = Rewards::ClaimService.new(user, movie_reward).call
        if result[:success]
          { success: true, message: 'Movie Ticket granted successfully' }
        else
          { success: false, message: result[:message] }
        end
      end

      def movie_reward
        @movie_reward ||= Reward.active.where(name: 'Free Movie Tickets').first
      end
  end
end
