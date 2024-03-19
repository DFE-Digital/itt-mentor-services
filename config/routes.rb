class SupportUserConstraint
  def self.matches?(request)
    service = HostingEnvironment.current_service(request)
    current_user = DfESignInUser.load_from_session(request.session, service:)&.user
    current_user&.support_user?
  end
end

Rails.application.routes.draw do
  scope via: :all do
    get "/404", to: "errors#not_found", as: :not_found
    get "/422", to: "errors#unprocessable_entity"
    get "/429", to: "errors#too_many_requests"
    get "/500", to: "errors#internal_server_error"
  end

  # User Account Details
  get "/account", to: "account#show"
  get "/sign-in", to: "sessions#new", as: :sign_in

  # Persona Sign In
  if ENV.fetch("SIGN_IN_METHOD", "persona") == "persona"
    get "/personas", to: "personas#index"
    get "/auth/developer/sign-out", to: "sessions#destroy", as: :sign_out
    post "/auth/developer/callback", to: "sessions#callback", as: :auth_callback
  else
    get("/auth/dfe/callback" => "sessions#callback")
    get("/auth/dfe/sign-out" => "sessions#destroy", as: :sign_out)
  end

  resources :service_updates, only: %i[index]
  namespace :api do
    resources :school_suggestions, only: [:index]
    resources :provider_suggestions, only: [:index]
  end

  draw :placements
  draw :claims

  get :healthcheck, controller: :heartbeat

  # GoodJob admin interface – only accessible to support users
  mount GoodJob::Engine => "/good_job", constraints: SupportUserConstraint
  get "/good_job", to: redirect("/support")

  # Deliberately cause a stack trace so Colin can test how it gets logged
  get "/explode" => ->(_env) { BOOM! }
end
