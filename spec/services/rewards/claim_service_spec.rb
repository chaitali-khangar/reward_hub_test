require 'rails_helper'

RSpec.describe Rewards::ClaimService, type: :service do
  let(:user) { FactoryBot.create(:user, total_points: 150) }
  let(:reward) { FactoryBot.create(:reward, points_req: 100) }

  describe '#call' do
    context 'when user has sufficient points' do
      it 'claims the reward successfully' do
        service = Rewards::ClaimService.new(user, reward)
        result = service.call

        expect(result[:success]).to be true
        expect(result[:message]).to eq('Reward claimed successfully')

        expect(user.reload.total_points).to eq(50)

        user_reward = user.user_rewards.last
        expect(user_reward.user).to eq(user)
        expect(user_reward.reward).to eq(reward)
        expect(user_reward.status).to eq('claimed')
      end
    end

    context 'when user has insufficient points' do
      let(:high_points_reward) { FactoryBot.create(:reward, points_req: 200) }

      it 'returns an error message' do
        service = Rewards::ClaimService.new(user, high_points_reward)
        result = service.call

        expect(result[:success]).to be false
        expect(result[:message]).to eq('Insufficient points')

        expect(user.reload.total_points).to eq(150)
        expect(UserReward.count).to eq(0)
      end
    end

    context 'when a error occurs' do
      it 'returns an error message and does not deduct points when reward is nil' do
        service = Rewards::ClaimService.new(user, nil)
        result = service.call

        expect(result[:success]).to be false
        expect(result[:message]).to eq('Reward not found')

        expect(user.reload.total_points).to eq(150)
        expect(UserReward.count).to eq(0)
      end

      it 'returns an error message and does not deduct points when user is nil' do
        service = Rewards::ClaimService.new(nil, reward)
        result = service.call

        expect(result[:success]).to be false
        expect(result[:message]).to eq('User not found')

        expect(user.reload.total_points).to eq(150)
        expect(UserReward.count).to eq(0)
      end
    end

    context 'when a general error occurs' do
      before do
        allow(user).to receive(:update!).and_raise(StandardError, 'Unexpected error')
      end

      it 'returns an error message' do
        service = Rewards::ClaimService.new(user, reward)
        result = service.call

        expect(result[:success]).to be false
        expect(result[:message]).to eq('Unexpected error')

        expect(user.reload.total_points).to eq(150)
        expect(UserReward.count).to eq(0)
      end
    end
  end
end
