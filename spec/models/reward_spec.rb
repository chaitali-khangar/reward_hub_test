require 'rails_helper'

RSpec.describe Reward, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:points_req) }
    it { should validate_presence_of(:valid_from) }
    it { should validate_presence_of(:valid_until) }

    it { should validate_numericality_of(:points_req).is_greater_than(0) }

    context 'when creating a reward' do
      let(:reward) { FactoryBot.build(:reward) }

      it 'is valid with valid attributes' do
        expect(reward).to be_valid
      end

      it 'is not valid without a name' do
        reward.name = nil
        expect(reward).not_to be_valid
      end

      it 'is not valid with negative points requirement' do
        reward.points_req = -50
        expect(reward).not_to be_valid
      end

      it 'is not valid when valid_until is before valid_from' do
        reward.valid_from = Time.zone.now
        reward.valid_until = 1.day.ago
        expect(reward).not_to be_valid
        expect(reward.errors[:valid_until]).to include('must be after valid_from')
      end
    end
  end

  describe 'factory' do
    it 'creates a valid reward' do
      reward = FactoryBot.build(:reward)
      expect(reward).to be_valid
    end

    it 'generates unique names for multiple rewards' do
      reward1 = FactoryBot.create(:reward)
      reward2 = FactoryBot.create(:reward)
      expect(reward1.name).not_to eq(reward2.name)
    end
  end
end
