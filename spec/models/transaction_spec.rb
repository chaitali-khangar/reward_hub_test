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
      expect(new_transaction.errors[:external_id]).to include('has already been taken')
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

    it 'creates a valid transaction' do
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

  describe '#calculate_points' do
    let!(:user) { FactoryBot.create(:user, country: 'USA') }

    context 'when the transaction is domestic' do
      it 'calculates the correct points' do
        transaction = FactoryBot.create(:transaction, user: user, amount: 250, country: 'USA')
        expect(transaction.send(:calculate_points)).to eq(20)
      end
    end

    context 'when the transaction is foreign' do
      it 'calculates double points' do
        transaction = FactoryBot.create(:transaction, user: user, amount: 250, country: 'India')
        expect(transaction.send(:calculate_points)).to eq(40)
      end
    end

    context 'when the transaction amount is less than $100' do
      it 'awards zero points' do
        transaction = FactoryBot.create(:transaction, user: user, amount: 50, country: 'USA')
        expect(transaction.send(:calculate_points)).to eq(0)
      end
    end
  end

  describe 'points update after transaction creation' do
    before(:each) do
      @user = FactoryBot.create(:user, country: 'USA')
    end

    it 'updates user points for domestic transactions' do
      expect do
        FactoryBot.create(:transaction, user: @user, amount: 300, country: 'USA')
      end.to change { @user.reload.total_points }.by(30)
    end

    it 'updates user points for foreign transactions' do
      expect do
        FactoryBot.create(:transaction, user: @user, amount: 300, country: 'Canada')
      end.to change { @user.reload.total_points }.by(60)
    end

    it 'does not update points if the amount is insufficient' do
      expect do
        FactoryBot.create(:transaction, user: @user, amount: 80, country: 'USA')
      end.not_to(change { @user.reload.total_points })
    end
  end
end
