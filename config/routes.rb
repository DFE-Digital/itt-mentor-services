Rails.application.routes.draw do
  scope via: :all do
    get "/404", to: "errors#not_found", as: :not_found
    get "/422", to: "errors#unprocessable_entity"
    get "/429", to: "errors#too_many_requests"
    get "/500", to: "errors#internal_server_error", as: :internal_server_error
  end

  # User Account Details
  get "/account", to: "account#show", constraints: ClaimsOnlyConstraint.new
  get "/sign-in", to: "sessions#new", as: :sign_in

  # Persona Sign In
  if ENV.fetch("SIGN_IN_METHOD", "persona") == "persona"
    get "/personas", to: "personas#index"
    get "/auth/developer/sign-out", to: "sessions#destroy", as: :sign_out
    post "/auth/developer/callback", to: "sessions#callback", as: :auth_callback
  else
    get("/auth/dfe/callback" => "sessions#callback")
    get("/auth/dfe/sign-out" => "sessions#destroy", as: :sign_out)
    get "/auth/failure", to: "sessions#failure"
  end

  namespace :api do
    resources :school_suggestions, only: [:index]
    resources :provider_suggestions, only: [:index]
  end

  draw :placements
  draw :claims

  # GoodJob admin interface – only accessible to support users
  mount GoodJob::Engine => "/good_job", constraints: SupportUserConstraint.new
  get "/good_job", to: redirect("/support")
end
