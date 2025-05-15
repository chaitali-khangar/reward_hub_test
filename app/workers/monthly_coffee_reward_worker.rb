class MonthlyCoffeeRewardWorker < BaseRewardWorker
  include Sidekiq::Worker

  def perform
    last_month = Time.zone.today.prev_month
    start_date = last_month.beginning_of_month
    end_date = last_month.end_of_month

    User.find_each do |user|
      next unless eligible_for_monthly_coffee?(user, start_date, end_date)

      process_reward(user, Rewards::CoffeeRewardService, 'monthly coffee', user: user, start_date: start_date,
                                                                           end_date: end_date, check_reward_already_granted: true)
    end
  end

  private

    def eligible_for_monthly_coffee?(user, start_date, end_date)
      # Hardcoded points threshold, can be replaced with a dynamic value
      monthly_points(user:, start_date:, end_date:) > 100
    end

    def monthly_points(user:, start_date:, end_date:)
      user.transactions.total_points_in_period(start_date, end_date)
    end
end
