# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  #
  # Routes for devices and their readings
  namespace :api do
    namespace :v1 do
      resources :devices, only: [:create] do
        member do
          get 'latest', to: 'devices#latest'
          get 'cumulative', to: 'devices#cumulative'
        end
      end
    end
  end
end
