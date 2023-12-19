scope module: :claims, as: :claims, constraints: { host: ENV["CLAIMS_HOST"] } do
  root to: "pages#index"

  resources :schools, only: [:index]

  namespace :support do
    root to: redirect("/support/schools")

    resources :schools do
      resources :claims
      resources :users
    end
  end
end
