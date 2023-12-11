Rails.application.routes.draw do
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  scope via: :all do
    get "/404", to: "errors#not_found"
    get "/422", to: "errors#unprocessable_entity"
    get "/429", to: "errors#too_many_requests"
    get "/500", to: "errors#internal_server_error"
  end

  # User Account Details
  get("/account", to: "account#index")

  # Persona Sign In
  get("/personas", to: "personas#index")
  get("/auth/developer/sign-out", to: "sessions#signout")
  post("/auth/developer/callback", to: "sessions#callback")
end
