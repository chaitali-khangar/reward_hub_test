require 'rails_helper'

RSpec.describe Rewards::CoffeeRewardService, type: :service do
  let(:user) { FactoryBot.create(:user, total_points: 150) }
  let(:start_date) { 1.month.ago.beginning_of_month }
  let(:end_date) { 1.month.ago.end_of_month }

  before(:each) do
    @coffee_reward = FactoryBot.create(:reward, name: 'Free Coffee', points_req: 100, valid_until: 1.month.from_now)
  end

  describe '#call' do
    context 'when user is not found' do
      it 'returns a user not found error' do
        result = Rewards::CoffeeRewardService.new(user: nil, start_date: start_date, end_date: end_date,
                                                  check_reward_already_granted: false).call
        expect(result[:success]).to be false
        expect(result[:message]).to eq('User not found')
      end
    end

    context 'when reward is not found' do
      before do
        @coffee_reward.update!(valid_from: 5.months.ago, valid_until: 1.month.ago)
      end

      it 'returns a reward not found error' do
        result = Rewards::CoffeeRewardService.new(user: user, start_date: start_date, end_date: end_date,
                                                  check_reward_already_granted: false).call
        expect(result[:success]).to be false
        expect(result[:message]).to eq('Reward not found')
      end
    end

    context 'when reward is not already granted and check_reward_already_granted is false' do
      it 'grants the coffee reward' do
        result = Rewards::CoffeeRewardService.new(user: user, start_date: start_date, end_date: end_date,
                                                  check_reward_already_granted: false).call
        expect(result[:success]).to be true
        expect(result[:message]).to eq('Free Coffee reward claimed successfully')
      end
    end

    context 'when reward is already granted and check_reward_already_granted is false' do
      before do
        FactoryBot.create(:user_reward, user: user, reward: @coffee_reward, created_at: start_date)
      end

      it 'grants the reward again if eligible' do
        result = Rewards::CoffeeRewardService.new(user: user, start_date: start_date, end_date: end_date,
                                                  check_reward_already_granted: false).call
        expect(result[:success]).to be true
        expect(result[:message]).to eq('Free Coffee reward claimed successfully')
      end
    end

    context 'when reward is not granted and check_reward_already_granted is true' do
      it 'grants the reward' do
        result = Rewards::CoffeeRewardService.new(user: user, start_date: start_date, end_date: end_date,
                                                  check_reward_already_granted: true).call
        expect(result[:success]).to be true
        expect(result[:message]).to eq('Free Coffee reward claimed successfully')
      end
    end

    context 'when reward is already granted and check_reward_already_granted is true' do
      before do
        FactoryBot.create(:user_reward, user: user, reward: @coffee_reward, created_at: start_date)
      end

      it 'does not grant the reward again' do
        result = Rewards::CoffeeRewardService.new(user: user, start_date: start_date, end_date: end_date,
                                                  check_reward_already_granted: true).call
        expect(result[:success]).to be true
        expect(result[:message]).to eq('Reward already granted')
      end
    end
  end
end
