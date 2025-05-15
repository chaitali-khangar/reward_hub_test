require 'rails_helper'

RSpec.describe Rewards::MovieTicketRewardService, type: :service do
  let!(:user) { FactoryBot.create(:user, total_points: 1300) }

  before(:each) do
    @movie_reward = FactoryBot.create(:reward, name: 'Free Movie Tickets', valid_from: Time.zone.today,
                                               valid_until: 1.year.from_now)
  end

  describe '#call' do
    context 'when user is not found' do
      it 'returns a user not found error' do
        result = Rewards::MovieTicketRewardService.new(user: nil).call
        expect(result[:success]).to be false
        expect(result[:message]).to eq('User not found')
      end
    end

    context 'when reward is not found' do
      before do
        @movie_reward.update!(valid_from: 1.year.before, valid_until: Time.zone.today - 1.day)
      end

      it 'returns a reward not found error' do
        result = Rewards::MovieTicketRewardService.new(user: user).call
        expect(result[:success]).to be false
        expect(result[:message]).to eq('Reward not found')
      end
    end

    context 'when the reward is successfully granted' do
      it 'returns a success message' do
        expect(Rewards::ClaimService).to receive(:new).with(user, @movie_reward).and_call_original
        result = Rewards::MovieTicketRewardService.new(user: user).call

        expect(result[:success]).to be true
        expect(result[:message]).to eq('Movie Ticket granted successfully')
      end
    end

    context 'when the claim service fails' do
      it 'returns the error message from the claim service' do
        result = Rewards::MovieTicketRewardService.new(user: nil).call
        expect(result[:success]).to be false
        expect(result[:message]).to eq('User not found')
      end
    end

    context 'when the reward is already granted' do
      before do
        FactoryBot.create(:user_reward, user: user, reward: @movie_reward, created_at: Time.zone.today)
      end

      it 'does not grant the reward again' do
        expect(Rewards::ClaimService).not_to receive(:new).with(user, @movie_reward)
        result = Rewards::MovieTicketRewardService.new(user: user).call
        expect(result[:success]).to be false
        expect(result[:message]).to eq('Reward already granted')
      end
    end
  end
end
