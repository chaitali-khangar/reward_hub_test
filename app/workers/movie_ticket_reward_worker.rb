class MovieTicketRewardWorker
  include Sidekiq::Worker

  def perform
    today = Time.zone.today
    start_date = today - 60.days

    # Find users whose first transaction is within the last 60 days and spending exceeds $1000
    User.find_each do |user|
      next unless eligible_for_movie_reward?(user, start_date, today)

      response = Rewards::MovieTicketRewardService.new(user:).call
      unless response[:success]
        Rails.logger.error("Failed to grant movie ticket to #{user.name}: #{response[:message]}")
      end
    end
  end

  private

    def eligible_for_movie_reward?(user, start_date, today)
      first_transaction_date = user.transactions.minimum(:created_at)&.to_date
      return false unless first_transaction_date

      # Check if the first transaction date is within the last 60 days
      return false unless first_transaction_date.between?(start_date, today)

      # Calculate total spending within 60 days from the first transaction
      total_spending = user.transactions
                           .where(created_at: first_transaction_date..(first_transaction_date + 60.days))
                           .sum(:amount)

      total_spending > 1000
    end
end
