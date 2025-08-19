Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :posts, only: [:index, :show, :destroy]
      resources :posts, only: [:create, :update], controller: 'posts_form'

      get 'daily_logs/by_date_range', to: 'daily_logs#by_date_range'
      resources :daily_logs, only: [:index, :show, :destroy]
      resources :daily_logs, only: [:create, :update], controller: 'daily_logs_form'

      resource :weather, only: :create
      post :signin, to: 'sessions#create'
      post :signup, to: 'registrations#create'
      post :oauth_register, to: 'registrations#oauth_register'
      resource :profile, only: [:show, :update]
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

    root "api/hello#index"
end
