scope module: :placements,
      as: :placements,
      constraints: {
        host: [
          ENV["PLACEMENTS_HOST"],
          *ENV.fetch("PLACEMENTS_HOSTS", "").split(","),
        ],
      } do
  root to: redirect("/sign-in")

  namespace :support do
    root to: redirect("/support/organisations")

    resources :support_users do
      collection { get :check }
      member { get :remove }
    end

    resources :organisations, only: %i[index new] do
      collection { get :select_type }
    end

    resources :schools, except: %i[edit update] do
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

        resources :mentors, only: %i[index new create show destroy] do
          member { get :remove }
          collection { get :check }
        end
      end
    end

    resources :providers, except: %i[edit update] do
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
      resources :users, only: %i[index new create show destroy] do
        member { get :remove }
        collection { get :check }
      end

      resources :mentors, only: %i[index new create show destroy] do
        member { get :remove }
        collection { get :check }
      end

      resources :placements, only: %i[index show destroy] do
        member { get :remove }
      end

      resources :partner_providers, only: %i[index new create show destroy] do
        member { get :remove }

        collection do
          get :check
          get :check_provider_option
          get :provider_options
        end
      end
    end
  end

  resources :providers, only: [:show] do
    scope module: :providers do
      resources :users, only: %i[index new create show destroy] do
        member { get :remove }
        collection { get :check }
      end

      resources :partner_schools, only: %i[index new create show destroy] do
        member { get :remove }

        collection do
          get :check
          get :check_school_option
          get :school_options
        end
      end
    end
  end
end
