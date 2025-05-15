class MovieTicketRewardWorker < BaseRewardWorker
  include Sidekiq::Worker

  def perform
    today = Time.zone.today
    start_date = today - 60.days

    User.find_each do |user|
      next unless eligible_for_movie_reward?(user, start_date, today)

      process_reward(user, Rewards::MovieTicketRewardService, 'movie ticket', user: user)
    end
  end

  private

    def eligible_for_movie_reward?(user, start_date, today)
      first_transaction_date = user.transactions.minimum(:created_at)&.to_date
      return false unless first_transaction_date&.between?(start_date, today)

      total_spending = user.transactions
                           .where(created_at: first_transaction_date..(first_transaction_date + 60.days))
                           .sum(:amount)

      total_spending > 1000
    end
end
