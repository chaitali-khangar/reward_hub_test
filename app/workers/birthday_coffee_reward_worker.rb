class BirthdayCoffeeRewardWorker < BaseRewardWorker
  include Sidekiq::Worker

  def perform
    current_month = Time.zone.today.month
    start_date = Time.zone.today.beginning_of_month
    end_date = Time.zone.today.end_of_month

    User.where("CAST(strftime('%m', birthdate) AS INTEGER) = ?", current_month).find_each do |user|
      process_reward(user, Rewards::CoffeeRewardService,
                     'birthday coffee',
                     user: user,
                     start_date: start_date,
                     end_date: end_date,
                     check_reward_already_granted: false)
    end
  end
end
