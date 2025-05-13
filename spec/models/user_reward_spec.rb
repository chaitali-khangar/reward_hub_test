require 'rails_helper'

RSpec.describe UserReward, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:reward) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }

    context 'status validation' do
      it 'is valid with status "Issued"' do
        user_reward = FactoryBot.build(:user_reward, status: 'Issued')
        expect(user_reward).to be_valid
      end

      it 'is valid with status "Redeemed"' do
        user_reward = FactoryBot.build(:user_reward, status: 'Redeemed', redeemed_at: Time.zone.now)
        expect(user_reward).to be_valid
      end

      it 'is not valid with an invalid status' do
        user_reward = FactoryBot.build(:user_reward, status: 'Pending')
        expect(user_reward).not_to be_valid
        expect(user_reward.errors[:status]).to include('Pending is not a valid status')
      end
    end

    context 'redeemed_at validation' do
      it 'is valid if status is "Issued" and redeemed_at is nil' do
        user_reward = FactoryBot.build(:user_reward, status: 'Issued', redeemed_at: nil)
        expect(user_reward).to be_valid
      end

      it 'is valid if status is "Redeemed" and redeemed_at is present' do
        user_reward = FactoryBot.build(:user_reward, status: 'Redeemed', redeemed_at: Time.zone.now)
        expect(user_reward).to be_valid
      end

      it 'is not valid if status is "Redeemed" and redeemed_at is nil' do
        user_reward = FactoryBot.build(:user_reward, status: 'Redeemed', redeemed_at: nil)
        expect(user_reward).not_to be_valid
        expect(user_reward.errors[:redeemed_at]).to include("must be present when status is 'Redeemed'")
      end
    end
  end

  describe 'factory' do
    it 'creates a valid user reward' do
      user_reward = FactoryBot.build(:user_reward)
      expect(user_reward).to be_valid
    end

    it 'associates with a user and reward' do
      user_reward = FactoryBot.create(:user_reward)
      expect(user_reward.user).to be_present
      expect(user_reward.reward).to be_present
    end
  end
end
