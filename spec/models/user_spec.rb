require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:birthdate) }
    it { should validate_presence_of(:country) }
    it { should validate_presence_of(:total_points) }

    context 'when user is persisted' do
      let!(:user) { FactoryBot.create(:user) }

      it 'validates presence of api_token' do
        user.api_token = nil
        expect(user).not_to be_valid
        expect(user.errors[:api_token]).to include("can't be blank")
      end
    end

    context 'when user is new (not persisted)' do
      let(:user) { FactoryBot.build(:user, api_token: nil) }

      it 'does not require api_token' do
        expect(user).to be_valid
      end
    end

    context 'uniqueness validator' do
      let!(:existing_user) { FactoryBot.create(:user) }

      it 'validates uniqueness of email' do
        new_user = FactoryBot.build(:user, email: existing_user.email)
        expect(new_user).not_to be_valid
        expect(new_user.errors[:email]).to include('has already been taken')
      end

      it 'validates uniqueness of api_token' do
        new_user = FactoryBot.build(:user, api_token: existing_user.api_token)
        expect(new_user).not_to be_valid
        expect(new_user.errors[:api_token]).to include('has already been taken')
      end
    end

    it { should validate_numericality_of(:total_points).is_greater_than_or_equal_to(0) }
  end

  describe 'indexes' do
    it { should have_db_index(:email).unique(true) }
    it { should have_db_index(:api_token).unique(true) }
  end

  describe 'callbacks' do
    it 'generates an API token before creation' do
      user = FactoryBot.create(:user, api_token: nil)
      expect(user.api_token).not_to be_nil
    end
    it 'does not regenerate API token on update' do
      user = FactoryBot.create(:user, api_token: 'original_token')
      original_token = user.api_token
      user.update(name: 'Updated Name')
      expect(user.api_token).to eq(original_token)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      user = FactoryBot.build(:user)
      expect(user).to be_valid
    end

    it 'creates a valid persisted user' do
      user = FactoryBot.create(:user)
      expect(user).to be_persisted
    end
  end
end
