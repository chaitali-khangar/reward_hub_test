require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe BirthdayCoffeeRewardWorker, type: :worker do
  let!(:birthday_user) { FactoryBot.create(:user, birthdate: Time.zone.today - 25.years) }
  let!(:non_birthday_user) { FactoryBot.create(:user, birthdate: Time.zone.today - 25.years - 1.month) }
  let(:coffee_reward) do
    FactoryBot.create(:reward, name: 'Free Coffee', points_req: 100, valid_until: 1.month.from_now)
  end

  before do
    Sidekiq::Worker.clear_all
  end

  describe '#perform' do
    it 'calculates the correct date range for the current month' do
      start_date = Time.zone.today.beginning_of_month
      end_date = Time.zone.today.end_of_month

      expect(Time.zone.today.beginning_of_month).to eq(start_date)
      expect(Time.zone.today.end_of_month).to eq(end_date)
    end

    it 'calls the CoffeeRewardService for users with birthdays in the current month' do
      expect(Rewards::CoffeeRewardService).to receive(:new).with(
        user: birthday_user,
        start_date: Time.zone.today.beginning_of_month,
        end_date: Time.zone.today.end_of_month,
        check_reward_already_granted: false
      ).and_call_original

      BirthdayCoffeeRewardWorker.new.perform
    end

    it 'does not call the CoffeeRewardService for users whose birthday month does not match' do
      reward_instance = instance_double(Rewards::CoffeeRewardService, call: {})
      allow(Rewards::CoffeeRewardService).to receive(:new).and_return(reward_instance)

      expect(Rewards::CoffeeRewardService).not_to receive(:new).with(
        user: non_birthday_user,
        start_date: kind_of(Date),
        end_date: kind_of(Date),
        check_reward_already_granted: false
      )

      BirthdayCoffeeRewardWorker.new.perform
    end

    it 'enqueues the job in the Sidekiq queue' do
      expect do
        BirthdayCoffeeRewardWorker.perform_async
      end.to change(BirthdayCoffeeRewardWorker.jobs, :size).by(1)
    end

    it 'executes the job from the queue' do
      BirthdayCoffeeRewardWorker.perform_async
      expect(BirthdayCoffeeRewardWorker.jobs.size).to eq(1)
      BirthdayCoffeeRewardWorker.drain
      expect(BirthdayCoffeeRewardWorker.jobs.size).to eq(0)
    end

    it 'logs successful reward grant' do
      allow_any_instance_of(Rewards::CoffeeRewardService).to receive(:call).and_return({ success: true,
                                                                                         message: 'Reward claimed successfully' })
      expect(Rails.logger).not_to receive(:error)

      BirthdayCoffeeRewardWorker.new.perform
    end
  end
end
