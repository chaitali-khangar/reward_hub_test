require 'rails_helper'

RSpec.describe Rewards::CoffeeRewardService, type: :service do
  let!(:user) { FactoryBot.create(:user, total_points: 150) }
  let(:start_date) { 1.month.ago.beginning_of_month }
  let(:end_date) { 1.month.ago.end_of_month }

  describe '#call' do
    context 'when user is not found' do
      it 'returns an error message' do
        result = Rewards::CoffeeRewardService.new(nil, start_date, end_date).call
        expect(result[:success]).to be false
        expect(result[:message]).to eq('User not found')
      end
    end

    context 'when reward is not found' do
      before do
        allow_any_instance_of(Rewards::CoffeeRewardService).to receive(:coffee_reward).and_return(nil)
      end

      it 'returns an error message' do
        result = Rewards::CoffeeRewardService.new(user, start_date, end_date).call
        expect(result[:success]).to be false
        expect(result[:message]).to eq('Reward not found')
      end
    end

    context 'when user has sufficient points' do
      let!(:valid_coffee_reward) do
        FactoryBot.create(:reward, name: 'Free Coffee', points_req: 100, valid_until: 1.month.from_now)
      end
      let!(:expired_coffee_reward) do
        FactoryBot.create(:reward, name: 'Free Coffee', points_req: 100, valid_until: 1.day.ago)
      end

      it 'claims the reward successfully' do
        FactoryBot.create(:transaction, user: user, amount: 1500, created_at: start_date)
        result = Rewards::CoffeeRewardService.new(user, start_date, end_date).call

        expect(result[:success]).to be true
        expect(result[:message]).to eq('Free Coffee reward claimed successfully')
      end
    end

    context 'when user does not have sufficient points' do
      let!(:valid_coffee_reward) do
        FactoryBot.create(:reward, name: 'Free Coffee', points_req: 100, valid_until: 1.month.from_now)
      end
      let!(:expired_coffee_reward) do
        FactoryBot.create(:reward, name: 'Free Coffee', points_req: 100, valid_until: 1.day.ago)
      end

      it 'returns points not sufficient error' do
        FactoryBot.create(:transaction, user: user, amount: 500, created_at: start_date)
        result = Rewards::CoffeeRewardService.new(user, start_date, end_date).call

        expect(result[:success]).to be false
        expect(result[:message]).to eq('Points not sufficient')
      end
    end

    context 'when reward is already granted in the month' do
      let!(:valid_coffee_reward) do
        FactoryBot.create(:reward, name: 'Free Coffee', points_req: 100, valid_until: 1.month.from_now)
      end
      let!(:expired_coffee_reward) do
        FactoryBot.create(:reward, name: 'Free Coffee', points_req: 100, valid_until: 1.day.ago)
      end

      before do
        FactoryBot.create(:user_reward, user: user, reward: valid_coffee_reward, created_at: start_date)
      end

      it 'does not grant the reward again' do
        FactoryBot.create(:transaction, user: user, amount: 1500, created_at: start_date)
        result = Rewards::CoffeeRewardService.new(user, start_date, end_date).call

        expect(result[:success]).to be false
        expect(result[:message]).to eq('Reward already granted')
      end
    end

    context 'when reward claim fails' do
      let!(:valid_coffee_reward) do
        FactoryBot.create(:reward, name: 'Free Coffee', points_req: 100, valid_until: 1.month.from_now)
      end

      it 'returns the error message from ClaimService' do
        user.update!(total_points: 50)
        result = Rewards::CoffeeRewardService.new(nil, start_date, end_date).call

        expect(result[:success]).to be false
      end
    end

    context 'when the reward is expired' do
      let!(:expired_coffee_reward) do
        FactoryBot.create(:reward, name: 'Free Coffee', points_req: 100, valid_until: 1.day.ago)
      end

      it 'does not grant the expired reward' do
        FactoryBot.create(:transaction, user: user, amount: 1500, created_at: start_date)
        result = Rewards::CoffeeRewardService.new(user, start_date, end_date).call

        expect(result[:success]).to be false
        expect(result[:message]).to eq('Reward not found')
      end
    end
  end
end
