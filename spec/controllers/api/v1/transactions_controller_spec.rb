require 'rails_helper'

RSpec.describe Api::V1::TransactionsController, type: :controller do
  render_views

  let!(:user) { FactoryBot.create(:user, api_token: 'valid_token') }

  before do
    request.headers['Authorization'] = user.api_token
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        transaction: {
          amount: 100.50,
          country: 'USA',
          external_id: SecureRandom.hex(10)
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new transaction' do
        expect do
          post :create, params: valid_attributes, format: :json
        end.to change(user.transactions, :count).by(1)

        expect(response).to have_http_status(:created)

        json_response = response.parsed_body['transaction']
        expect(json_response).to include(
          'user_id' => user.id,
          'amount' => 100.50,
          'country' => 'USA'
        )
        expect(json_response.keys).to include('id', 'external_id', 'created_at')
      end
    end
  end

  describe 'GET #index' do
    before do
      FactoryBot.create_list(:transaction, 3, user: user)
    end

    it 'returns a list of transactions' do
      get :index, format: :json
      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json.length).to eq(3)
    end
  end
end
