class MonthlyCoffeeRewardWorker
  include Sidekiq::Worker

  def perform
    last_month = Time.zone.today.prev_month
    start_date = last_month.beginning_of_month
    end_date = last_month.end_of_month

    User.find_each do |user|
      # Right now harcorded but we can use coffee_reward.point_req
      next if monthly_points(user:, start_date:, end_date:) <= 100

      response = Rewards::CoffeeRewardService.new(user:,
                                                  start_date:,
                                                  end_date:,
                                                  check_reward_already_granted: true).call

      unless response[:success]
        Rails.logger.error("Failed to grant coffee reward to #{user.name}: #{response[:message]}")
      end
    end
  end

  private

    def monthly_points(user:, start_date:, end_date:)
      user.transactions.total_points_in_period(start_date, end_date)
    end
end
