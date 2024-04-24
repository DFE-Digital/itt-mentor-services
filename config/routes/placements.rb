scope module: :placements,
      as: :placements,
      constraints: {
        host: [
          ENV["PLACEMENTS_HOST"],
          *ENV.fetch("PLACEMENTS_HOSTS", "").split(","),
        ],
      } do
  root to: "pages#start"

  scope module: :pages do
    get :start
    get :cookies, action: :show, page: :cookies
    get :privacy, action: :show, page: :privacy
    get :accessibility, action: :show, page: :accessibility
  end

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

        resources :placements, only: %i[index new create show destroy] do
          member { get :remove }
          collection { get :check }
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

      resources :placements, only: %i[index update show destroy] do
        member { get :remove }
        get :edit_provider, on: :member
        get :edit_mentors, on: :member

        scope module: :placements do
          resources :build do
            collection do
              get :add_phase
              get :add_subject
              get :add_mentors
              get :check_your_answers
            end
          end
        end
      end

      resources :school_contacts, except: %i[show index destroy] do
        collection { get :check }
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

      resources :placements, only: %i[index show]
    end
  end
end
