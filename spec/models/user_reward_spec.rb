require 'rails_helper'

RSpec.describe UserReward, type: :model do
  let!(:user) { FactoryBot.create(:user) }
  let!(:reward) { FactoryBot.create(:reward) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:reward) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }

    context 'status validation' do
      it 'defines the correct enum values' do
        expect(UserReward.statuses.keys).to contain_exactly('claimed', 'redeemed', 'expired')
      end
    end

    describe 'default status' do
      it 'sets the status to claimed by default' do
        user_reward = UserReward.build(user: user, reward: reward)
        expect(user_reward.status).to eq('claimed')
      end
    end

    context 'redeemed_at validation' do
      it 'is valid if status is "claimed" and redeemed_at is nil' do
        user_reward = FactoryBot.build(:user_reward, status: 'claimed', redeemed_at: nil)
        expect(user_reward).to be_valid
      end

      it 'is valid if status is "redeemed" and redeemed_at is present' do
        user_reward = FactoryBot.build(:user_reward, status: 'redeemed', redeemed_at: Time.zone.now)
        expect(user_reward).to be_valid
      end

      it 'is not valid if status is "redeemed" and redeemed_at is nil' do
        user_reward = FactoryBot.build(:user_reward, status: 'redeemed', redeemed_at: nil)
        expect(user_reward).not_to be_valid
        expect(user_reward.errors[:redeemed_at]).to include("must be present when status is 'redeemed'")
      end
    end
  end

  describe 'factory' do
    it 'creates a valid user reward' do
      user_reward = FactoryBot.build(:user_reward, user: user, reward: reward)
      expect(user_reward).to be_valid
    end

    it 'associates with a user and reward' do
      user_reward = FactoryBot.create(:user_reward, user: user, reward: reward)
      expect(user_reward.user).to be_present
      expect(user_reward.reward).to be_present
    end
  end
end
