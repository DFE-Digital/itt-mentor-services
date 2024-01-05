Rails.application.routes.draw do
  scope via: :all do
    get "/404", to: "errors#not_found"
    get "/422", to: "errors#unprocessable_entity"
    get "/429", to: "errors#too_many_requests"
    get "/500", to: "errors#internal_server_error"
  end

  # User Account Details
  get "/account", to: "account#index"
  get "/sign-in", to: "sessions#new", as: :sign_in

  # Persona Sign In
  case ENV.fetch("SIGN_IN_METHOD")
  when "persona"
    get "/personas", to: "personas#index"
    get "/auth/developer/sign-out", to: "sessions#destroy", as: :sign_out
    post "/auth/developer/callback", to: "sessions#callback", as: :auth_callback
  end

  resources :service_updates, only: %i[index]
  namespace :api do
    resources :school_suggestions, only: [:index]
  end

  draw :placements
  draw :claims

  get :healthcheck, controller: :heartbeat
end
