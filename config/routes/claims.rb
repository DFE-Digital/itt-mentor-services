scope module: :claims, as: :claims, constraints: { host: ENV["CLAIMS_HOST"] } do
  root to: "pages#index"

  resources :schools, only: [:index]

  namespace :support do
    root to: redirect("/support/schools")

    resources :schools, only: %i[index show] do
      resources :claims
      resources :users, only: [:index]
    end
  end
end
