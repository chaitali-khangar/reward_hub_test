require 'rails_helper'

RSpec.describe Api::V1::UserController, type: :controller do
  render_views

  let(:user) { FactoryBot.create(:user, api_token: 'valid_token') }

  describe 'POST #create' do
    let(:valid_attributes) do
      { user: { name: 'John Doe', email: 'john@example.com', birthdate: '1990-01-01', country: 'USA' } }
    end
    let(:invalid_attributes) { { user: { name: '', email: '', birthdate: '', country: '' } } }

    context 'when valid parameters are provided' do
      it 'creates a new user and returns success' do
        expect do
          post :create, params: valid_attributes, format: :json
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        json = response.parsed_body
        expect(json['message']).to eq('User created successfully')
        expect(json['user']).to include(
          'name' => 'John Doe',
          'email' => 'john@example.com'
        )
      end
    end

    context 'when invalid parameters are provided' do
      it 'does not create a user and returns errors' do
        expect do
          post :create, params: invalid_attributes, format: :json
        end.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = response.parsed_body
        expect(json['errors']).to include("Name can't be blank")
      end
    end
  end

  describe 'GET #me' do
    before do
      request.headers['Authorization'] = user.api_token
    end

    context 'with valid API token' do
      it 'returns the current user data' do
        get :me, format: :json

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response).to include(
          'id' => user.id,
          'name' => user.name,
          'email' => user.email,
          'api_token' => user.api_token,
          'country' => user.country,
          'total_points' => user.total_points
        )
        expect(json_response).to include('birthdate', 'created_at', 'updated_at')
      end
    end

    context 'with invalid API token' do
      it 'returns unauthorized' do
        request.headers['Authorization'] = 'invalid_token'
        get :me, format: :json
        expect(response).to have_http_status(:unauthorized)
        json = response.parsed_body
        expect(json['error']).to eq('Invalid or expired API token')
      end
    end

    context 'without API token' do
      it 'returns unauthorized' do
        request.headers['Authorization'] = nil
        get :me, format: :json
        expect(response).to have_http_status(:unauthorized)
        json = response.parsed_body
        expect(json['error']).to eq('Authorization header missing')
      end
    end
  end
end
