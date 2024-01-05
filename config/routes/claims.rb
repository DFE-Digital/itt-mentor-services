scope module: :claims, as: :claims, constraints: { host: ENV["CLAIMS_HOST"] } do
  root to: "pages#index"

  resources :schools, only: [:index]

  namespace :support do
    root to: redirect("/support/schools")

    resources :schools, except: %i[destroy update] do
      collection { get :check }

      resources :claims
      resources :users, only: [:index]
    end
  end
end
