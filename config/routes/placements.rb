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
    get :terms_and_conditions, action: :show, page: :terms_and_conditions
  end

  namespace :support do
    root to: redirect("/support/organisations")

    get :settings, to: "settings#index"

    resources :mailers, only: :index

    resources :support_users, only: %i[index show destroy] do
      member { get :remove }

      collection do
        get "new", to: "support_users/add_support_user#new", as: :new_add_support_user
        get "new/:step", to: "support_users/add_support_user#edit", as: :add_support_user
        put "new/:step", to: "support_users/add_support_user#update"
      end
    end

    resources :organisations, only: %i[index] do
      collection do
        get "new", to: "organisations/add_organisation#new", as: :new_add_organisation
        get "new/:step", to: "organisations/add_organisation#edit", as: :add_organisation
        put "new/:step", to: "organisations/add_organisation#update"
      end
    end

    resources :schools, only: [:show] do
      scope module: :schools do
        resources :users, only: %i[index show destroy] do
          member { get :remove }

          collection do
            get "new", to: "users/add_user#new", as: :new_add_user
            get "new/:step", to: "users/add_user#edit", as: :add_user
            put "new/:step", to: "users/add_user#update"
          end
        end

        resources :mentors, only: %i[index new create show destroy] do
          member { get :remove }
          collection { get :check }
        end

        resources :placements, only: %i[index new create show destroy] do
          member { get :remove }
          collection { get :check }

          collection do
            get "new", to: "placements/add_placement#new", as: :new_add_placement
            get "new/:step", to: "placements/add_placement#edit", as: :add_placement
            put "new/:step", to: "placements/add_placement#update"
          end
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
        resources :users, only: %i[index show destroy] do
          member { get :remove }

          collection do
            get "new", to: "users/add_user#new", as: :new_add_user
            get "new/:step", to: "users/add_user#edit", as: :add_user
            put "new/:step", to: "users/add_user#update"
          end
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

  resources :organisations, only: %i[index show]
  resources :schools, only: %i[show] do
    scope module: :schools do
      resources :users, only: %i[index show destroy] do
        member { get :remove }

        collection do
          get "new", to: "users/add_user#new", as: :new_add_user
          get "new/:step", to: "users/add_user#edit", as: :add_user
          put "new/:step", to: "users/add_user#update"
        end
      end

      resources :mentors, only: %i[index new create show destroy] do
        member { get :remove }
        collection { get :check }
      end

      resources :placements, only: %i[index update show destroy] do
        member do
          get :remove
          get "edit", to: "placements/edit_placement#new", as: :new_edit_placement
          get "edit/:step", to: "placements/edit_placement#edit", as: :edit_placement
          put "edit/:step", to: "placements/edit_placement#update"
        end

        get :edit_mentors, on: :member
        get :edit_year_group, on: :member

        collection do
          get "new", to: "placements/add_placement#new", as: :new_add_placement
          get "new/:step", to: "placements/add_placement#edit", as: :add_placement
          put "new/:step", to: "placements/add_placement#update"
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
      resources :users, only: %i[index show destroy] do
        member { get :remove }

        collection do
          get "new", to: "users/add_user#new", as: :new_add_user
          get "new/:step", to: "users/add_user#edit", as: :add_user
          put "new/:step", to: "users/add_user#update"
        end
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

  resources :placements, only: %i[index show]
end
