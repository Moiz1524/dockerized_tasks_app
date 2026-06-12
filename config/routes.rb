require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  root "tasks#index"

  resources :tasks do
    member do
      post :copy
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
