Rails.application.routes.draw do
  resource :session
  resource :registration, only: [ :new, :create ]
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#show"

  get "search", to: "search#index", as: :search
  resource :profile, only: [ :show, :edit, :update, :destroy ]

  resources :organizations do
    post :switch, on: :member
    resources :organization_memberships, only: [ :new, :create, :destroy ], shallow: true
  end

  resources :projects do
    member do
      get :kanban
    end
  end
  resources :tasks
end
