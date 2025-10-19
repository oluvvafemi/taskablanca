Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#show"

  get "search", to: "search#index", as: :search

  resources :projects do
    member do
      get :kanban
    end
  end
  resources :tasks
end
