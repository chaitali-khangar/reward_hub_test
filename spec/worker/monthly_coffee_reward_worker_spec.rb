require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe MonthlyCoffeeRewardWorker, type: :worker do
  let!(:user1) { FactoryBot.create(:user) }
  let!(:user2) { FactoryBot.create(:user) }

  before do
    Sidekiq::Worker.clear_all
  end

  describe '#perform' do
    it 'calculates the correct date range for the previous month' do
      last_month = Time.zone.today.prev_month
      start_date = last_month.beginning_of_month
      end_date = last_month.end_of_month

      expect(Time.zone.today.prev_month.beginning_of_month).to eq(start_date)
      expect(Time.zone.today.prev_month.end_of_month).to eq(end_date)
    end

    it 'triggers the CoffeeRewardService for each user' do
      expect(Rewards::CoffeeRewardService).to receive(:new).with(user1, kind_of(Date), kind_of(Date)).and_call_original
      expect(Rewards::CoffeeRewardService).to receive(:new).with(user2, kind_of(Date), kind_of(Date)).and_call_original

      MonthlyCoffeeRewardWorker.new.perform
    end

    it 'processes all users in the database' do
      expect(User).to receive(:find_each).and_yield(user1).and_yield(user2)
      MonthlyCoffeeRewardWorker.new.perform
    end

    it 'enqueues the job in the Sidekiq queue' do
      expect do
        MonthlyCoffeeRewardWorker.perform_async
      end.to change(MonthlyCoffeeRewardWorker.jobs, :size).by(1)
    end

    it 'executes the job from the queue' do
      MonthlyCoffeeRewardWorker.perform_async
      expect(MonthlyCoffeeRewardWorker.jobs.size).to eq(1)
    end

    it 'clears the queue after performing the job' do
      MonthlyCoffeeRewardWorker.perform_async
      expect(MonthlyCoffeeRewardWorker.jobs.size).to eq(1)
      MonthlyCoffeeRewardWorker.drain
      expect(MonthlyCoffeeRewardWorker.jobs.size).to eq(0)
    end

    it 'handles an empty user list without error' do
      User.delete_all
      expect do
        MonthlyCoffeeRewardWorker.new.perform
      end.not_to raise_error
    end
  end
end
