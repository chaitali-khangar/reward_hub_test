class MonthlyCoffeeRewardWorker
  include Sidekiq::Worker

  def perform
    last_month = Time.zone.today.prev_month
    start_date = last_month.beginning_of_month
    end_date = last_month.end_of_month

    User.find_each do |user|
      Rewards::CoffeeRewardService.new(user, start_date, end_date).call
    end
  end
end
