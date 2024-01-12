scope module: :claims, as: :claims, constraints: { host: ENV["CLAIMS_HOST"] } do
  root to: redirect("/schools")

  resources :schools, only: %i[index show] do
    scope module: :schools do
      resources :claims, only: %i[index show]
      resources :users, only: %i[index show]
    end
  end

  namespace :support do
    root to: redirect("/support/schools")

    resources :claims, only: %i[index show]
    resources :users, only: %i[index show]

    resources :schools, except: %i[destroy update] do
      get :check, on: :collection

      scope module: :schools do
        resources :claims
        resources :mentors, only: %i[index]
        resources :providers, only: %i[index]
        resources :users, only: %i[index new create show] do
          get :check, on: :collection
        end
      end
    end
  end
end
