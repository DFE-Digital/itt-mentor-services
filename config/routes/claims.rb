scope module: :claims, as: :claims, constraints: { host: ENV["CLAIMS_HOST"] } do
  root to: redirect("/sign-in")

  scope module: :pages do
    get :feedback
  end

  resources :schools, only: %i[index show] do
    scope module: :schools do
      resources :claims, only: %i[index new show] do
        member do
          get "/edit/:step", to: "claims#edit", as: "edit"
          patch "/update/:step", to: "claims#update", as: "update"
        end
      end
      resources :users, only: %i[index new create show] do
        get :check, on: :collection
      end
    end
  end

  namespace :support do
    root to: redirect("/support/schools")

    resources :claims, only: %i[index show]
    resources :support_users do
      get :check, on: :collection
      get :remove, on: :member
    end

    resources :schools, except: %i[destroy update] do
      collection do
        get :check
        get :check_school_option
        get :school_options
      end

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
