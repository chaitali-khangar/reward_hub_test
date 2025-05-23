require 'sidekiq/web'
require 'sidekiq/cron/web'
Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    namespace :v1 do
      resources :user, only: [:create]
      get "/me" => "user#me"

      resources :transactions, only: [:create, :index]

      resources :reward, only: [] do
        member do
          post 'claim'
        end
        collection do
          get 'available'
          get 'claimed'
        end
      end
    end
  end
end
