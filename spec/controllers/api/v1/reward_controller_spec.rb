require 'rails_helper'

RSpec.describe Api::V1::RewardController, type: :controller do
  render_views

  let(:user) { FactoryBot.create(:user, api_token: 'valid_token', total_points: 300) }
  let(:reward) { FactoryBot.create(:reward, points_req: 100) }

  before do
    request.headers['Authorization'] = user.api_token
  end

  describe 'GET #available' do
    before do
      coffee_reward = FactoryBot.create(:reward, name: 'Coffee', points_req: 50)
      movie_reward = FactoryBot.create(:reward, name: 'Movie Ticket', points_req: 200)
      user.rewards << [coffee_reward, movie_reward]
    end

    it 'returns available rewards based on user points' do
      get :available, format: :json
      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['available_rewards'].size).to eq(2)
      expect(json['available_rewards'].pluck(:name)).to contain_exactly('Coffee', 'Movie Ticket')
    end
  end

  describe 'GET #claimed' do
    let!(:claimed_reward_1) { FactoryBot.create(:reward, name: 'Free Coffee') }
    let!(:claimed_reward_2) { FactoryBot.create(:reward, name: 'Free Movie Ticket') }
    let!(:user_claimed_reward_1) do
      FactoryBot.create(:user_reward, user: user, reward: claimed_reward_1, status: :claimed)
    end
    let!(:user_claimed_reward_2) do
      FactoryBot.create(:user_reward, user: user, reward: claimed_reward_2, status: :claimed)
    end

    context 'when the user has claimed rewards' do
      it 'returns a successful response' do
        get :claimed, format: :json
        expect(response).to have_http_status(:ok)
      end

      it 'returns the claimed rewards in JSON format' do
        get :claimed, format: :json
        json_response = response.parsed_body
        expect(json_response['claimed_rewards'].size).to eq(2)

        reward_names = json_response['claimed_rewards'].pluck('name')
        expect(reward_names).to include('Free Coffee', 'Free Movie Ticket')
      end
    end

    context 'when the user has no claimed rewards' do
      before do
        user.user_rewards.where(status: :claimed).destroy_all
      end

      it 'returns a successful response' do
        get :claimed, format: :json
        expect(response).to have_http_status(:ok)
      end

      it 'returns an empty list of rewards' do
        get :claimed, format: :json
        json_response = response.parsed_body
        expect(json_response['claimed_rewards']).to eq([])
      end
    end
  end

  describe 'POST #claim' do
    context 'when reward exists and points are sufficient' do
      it 'claims the reward successfully' do
        post :claim, params: { id: reward.id }, format: :json
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json['message']).to eq('Reward claimed successfully')
        expect(user.reload.total_points).to eq(200)
      end
    end

    context 'when reward does not exist' do
      it 'returns not found' do
        post :claim, params: { id: 999 }, format: :json
        expect(response).to have_http_status(:not_found)
        json = response.parsed_body
        expect(json['error']).to eq('Reward not found')
      end
    end

    context 'when insufficient points' do
      let(:high_point_reward) { FactoryBot.create(:reward, points_req: 500) }

      it 'returns an error message' do
        post :claim, params: { id: high_point_reward.id }, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = response.parsed_body
        expect(json['error']).to eq('Insufficient points')
      end
    end
  end
end
