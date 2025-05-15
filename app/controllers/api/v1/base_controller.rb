module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :authenticate_user!

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      private

        # Extract API token from headers and find the user
        def authenticate_user!
          api_token = request.headers['Authorization']
          if api_token.blank?
            render json: { error: 'Authorization header missing' }, status: :unauthorized
            return
          end

          @user = User.find_by(api_token: api_token)
          return unless @user.nil?

          render json: { error: 'Invalid or expired API token' }, status: :unauthorized
        end

        def record_not_found(exception)
          render json: { error: "#{exception.model} not found" }, status: :not_found
        end
    end
  end
end
