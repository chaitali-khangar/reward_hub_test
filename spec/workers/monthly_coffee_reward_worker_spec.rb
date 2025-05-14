require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe MonthlyCoffeeRewardWorker, type: :worker do
  let!(:user_with_points) { FactoryBot.create(:user, total_points: 150) }
  let!(:user_without_points) { FactoryBot.create(:user, total_points: 0) }
  let(:coffee_reward) do
    FactoryBot.create(:reward, name: 'Free Coffee', points_req: 100, valid_until: 1.month.from_now)
  end
  let(:start_date) { 1.month.ago.beginning_of_month }

  before do
    Sidekiq::Worker.clear_all
  end

  describe '#perform' do
    it 'calculates the correct date range for the previous month' do
      last_month = Time.zone.today.prev_month
      start_date = last_month.beginning_of_month
      end_date = last_month.end_of_month

      expect(last_month.beginning_of_month).to eq(start_date)
      expect(last_month.end_of_month).to eq(end_date)
    end

    it 'does not call the CoffeeRewardService if user points are less than 100' do
      FactoryBot.create(:transaction, user: user_without_points, amount: 50, created_at: start_date)
      expect(Rewards::CoffeeRewardService).not_to receive(:new)

      MonthlyCoffeeRewardWorker.new.perform
    end

    it 'calls the CoffeeRewardService if user points are greater or equal to 100' do
      last_month = Time.zone.today.prev_month
      FactoryBot.create(:transaction, user: user_with_points, amount: 1500, created_at: start_date)

      expect(Rewards::CoffeeRewardService).to receive(:new).with(
        user: user_with_points,
        start_date: last_month.beginning_of_month,
        end_date: last_month.end_of_month,
        check_reward_already_granted: true
      ).and_call_original

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
      MonthlyCoffeeRewardWorker.drain
      expect(MonthlyCoffeeRewardWorker.jobs.size).to eq(0)
    end

    context 'when reward was already granted' do
      before do
        FactoryBot.create(:user_reward, user: user_with_points, reward: coffee_reward,
                                        created_at: Time.zone.today.beginning_of_month)
      end

      it 'does not grant the reward again' do
        expect(Rewards::CoffeeRewardService).not_to receive(:new).with(
          user: user_with_points,
          start_date: kind_of(Date),
          end_date: kind_of(Date),
          check_reward_already_granted: true
        )
        MonthlyCoffeeRewardWorker.new.perform
      end
    end
  end

  describe '#monthly_points' do
    it 'returns the total points accumulated by the user in the given period' do
      worker = MonthlyCoffeeRewardWorker.new
      start_date = Time.zone.today.beginning_of_month
      end_date = Time.zone.today.end_of_month
      FactoryBot.create(:transaction, user: user_with_points, amount: 1000, created_at: start_date)

      points = worker.send(:monthly_points, user: user_with_points, start_date: start_date, end_date: end_date)
      expect(points).to eq(100)
    end

    it 'returns zero if no transactions are present for the user in the given period' do
      worker = MonthlyCoffeeRewardWorker.new
      start_date = Time.zone.today.beginning_of_month
      end_date = Time.zone.today.end_of_month

      points = worker.send(:monthly_points, user: user_without_points, start_date: start_date, end_date: end_date)
      expect(points).to eq(0)
    end
  end
end
