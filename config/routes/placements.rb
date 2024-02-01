scope module: :placements,
      as: :placements,
      constraints: {
        host: ENV["PLACEMENTS_HOST"],
      } do
  root to: redirect("/sign-in")

  scope module: :pages do
    get :feedback
  end

  namespace :support do
    root to: redirect("/support/organisations")

    resources :organisations, only: %i[index new] do
      collection { get :select_type }
    end

    resources :schools, expect: %i[edit update show] do
      collection do
        get :check
        get :check_school_option
        get :school_options
      end

      scope module: :schools do
        resources :users, only: %i[index new create show destroy] do
          member { get :remove }
          collection { get :check }
        end
      end
    end

    resources :providers, expect: %i[edit update show] do
      collection do
        get :check
        get :check_provider_option
        get :provider_options
      end

      scope module: :providers do
        resources :users, only: %i[index new create show destroy] do
          member { get :remove }
          collection { get :check }
        end
      end
    end
  end

  resources :organisations, only: [:index]
  resources :schools, only: %i[show] do
    scope module: :schools do
      resources :users, only: %i[index new create show] do
        get :check, on: :collection
      end
    end
  end

  resources :providers, only: [:show] do
    scope module: :providers do
      resources :users, only: %i[index new create show] do
        get :check, on: :collection
      end
    end
  end
end
