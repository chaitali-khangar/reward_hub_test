require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe MovieTicketRewardWorker, type: :worker do
  let!(:user_eligible) { FactoryBot.create(:user) }
  let!(:user_not_eligible) { FactoryBot.create(:user) }

  before do
    Sidekiq::Worker.clear_all
  end

  describe '#perform' do
    it 'grants the movie ticket if spending exceeds $1000 within 60 days of first transaction' do
      FactoryBot.create(:transaction, user: user_eligible, amount: 1100, created_at: Time.zone.today - 30.days)
      expect(Rewards::MovieTicketRewardService).to receive(:new).with(user: user_eligible).and_call_original

      MovieTicketRewardWorker.new.perform
    end

    it 'does not grant the reward if spending is below $1000' do
      FactoryBot.create(:transaction, user: user_not_eligible, amount: 900, created_at: Time.zone.today - 30.days)
      expect(Rewards::MovieTicketRewardService).not_to receive(:new).with(user: user_not_eligible)

      MovieTicketRewardWorker.new.perform
    end

    it 'does not grant the reward if the first transaction was more than 60 days ago' do
      FactoryBot.create(:transaction, user: user_eligible, amount: 1500, created_at: Time.zone.today - 70.days)
      expect(Rewards::MovieTicketRewardService).not_to receive(:new).with(user: user_eligible)

      MovieTicketRewardWorker.new.perform
    end

    it 'enqueues the job in the Sidekiq queue' do
      expect do
        MovieTicketRewardWorker.perform_async
      end.to change(MovieTicketRewardWorker.jobs, :size).by(1)
    end

    it 'executes the job from the queue' do
      MovieTicketRewardWorker.perform_async
      expect(MovieTicketRewardWorker.jobs.size).to eq(1)

      MovieTicketRewardWorker.drain
      expect(MovieTicketRewardWorker.jobs.size).to eq(0)
    end
  end
end
