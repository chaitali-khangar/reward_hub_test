class BirthdayCoffeeRewardWorker
  include Sidekiq::Worker

  def perform
    current_month = Time.zone.today.month
    start_date = Time.zone.today.beginning_of_month
    end_date = Time.zone.today.end_of_month

    # For sqlite
    User.where("CAST(strftime('%m', birthdate) AS INTEGER) = ?", current_month).find_each do |user|
      Rewards::CoffeeRewardService.new(
        user:,
        start_date:,
        end_date:,
        check_reward_already_granted: false
      ).call
    end
  end
end
