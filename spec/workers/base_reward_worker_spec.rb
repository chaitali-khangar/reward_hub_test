require 'rails_helper'

RSpec.describe BaseRewardWorker, type: :worker do
  let(:user) { double('User', name: 'John Doe') }
  let(:reward_name) { 'Free Coffee' }
  let(:reward_service) { double('RewardService') }
  let(:response) { { success: false, message: 'Some error occurred' } }

  subject { described_class.new }

  describe '#log_failure' do
    it 'logs an error message when reward processing fails' do
      expect(Rails.logger).to receive(:error).with("Failed to grant #{reward_name} to #{user.name}: Some error occurred")
      subject.send(:log_failure, user, reward_name, 'Some error occurred')
    end
  end

  describe '#process_reward' do
    context 'when the reward processing is successful' do
      let(:response) { { success: true, message: 'Reward granted successfully' } }

      it 'does not log an error message' do
        expect(Rails.logger).not_to receive(:error)
        allow(reward_service).to receive(:new).with(user: user).and_return(double(call: response))

        subject.send(:process_reward, user, reward_service, reward_name, user: user)
      end
    end

    context 'when the reward processing fails' do
      it 'logs an error message' do
        expect(Rails.logger).to receive(:error).with("Failed to grant #{reward_name} to #{user.name}: Some error occurred")
        allow(reward_service).to receive(:new).with(user: user).and_return(double(call: response))

        subject.send(:process_reward, user, reward_service, reward_name, user: user)
      end
    end
  end
end
