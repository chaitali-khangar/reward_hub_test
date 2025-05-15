class BaseRewardWorker
  include Sidekiq::Worker

  private

    def log_failure(user, reward_name, message)
      Rails.logger.error("Failed to grant #{reward_name} to #{user.name}: #{message}")
    end

    def process_reward(user, reward_service, reward_name, **options)
      response = reward_service.new(**options).call
      log_failure(user, reward_name, response[:message]) unless response[:success]
    end
end
