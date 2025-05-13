require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:country) }
    it { should validate_presence_of(:external_id) }

    it 'uniqueness validator for external_id' do
      user = FactoryBot.create(:user)
      existing_transaction = FactoryBot.create(:transaction, user: user)
      new_transaction = FactoryBot.build(:transaction, user: user, external_id: existing_transaction.external_id)
      expect(new_transaction).not_to be_valid
    end

    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_numericality_of(:amount).is_less_than_or_equal_to(10_000_000) }

    context 'when creating a transaction' do
      let(:user) { FactoryBot.create(:user) }

      it 'is valid with valid attributes' do
        transaction = FactoryBot.build(:transaction, user: user)
        expect(transaction).to be_valid
      end

      it 'is not valid with a negative amount' do
        transaction = FactoryBot.build(:transaction, user: user, amount: -100.00)
        expect(transaction).not_to be_valid
      end

      it 'is not valid with zero amount' do
        transaction = FactoryBot.build(:transaction, user: user, amount: 0)
        expect(transaction).not_to be_valid
      end

      it 'is not valid with an amount exceeding the limit' do
        transaction = FactoryBot.build(:transaction, user: user, amount: 20_000_000)
        expect(transaction).not_to be_valid
      end

      it 'is not valid without an external_id' do
        transaction = FactoryBot.build(:transaction, user: user, external_id: nil)
        expect(transaction).not_to be_valid
      end

      it 'does not allow duplicate external_id' do
        existing_transaction = FactoryBot.create(:transaction, user: user)
        duplicate_transaction = FactoryBot.build(:transaction, user: user,
                                                               external_id: existing_transaction.external_id)
        expect(duplicate_transaction).not_to be_valid
        expect(duplicate_transaction.errors[:external_id]).to include('has already been taken')
      end
    end
  end

  describe 'factory' do
    let(:user) { FactoryBot.create(:user) }

    it 'FactoryBot.creates a valid transaction' do
      transaction = FactoryBot.build(:transaction, user: user)
      expect(transaction).to be_valid
    end

    it 'associates with a user' do
      transaction = FactoryBot.create(:transaction, user: user)
      expect(transaction.user).to be_present
    end

    it 'generates a unique external_id' do
      transaction1 = FactoryBot.create(:transaction, user: user)
      transaction2 = FactoryBot.create(:transaction, user: user)
      expect(transaction1.external_id).not_to eq(transaction2.external_id)
    end
  end
end
