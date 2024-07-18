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

        resources :placements, only: %i[index show destroy] do
          member do
            get :remove
            get "edit", to: "placements/edit_placement#new", as: :new_edit_placement
            get "edit/:step", to: "placements/edit_placement#edit", as: :edit_placement
            put "edit/:step", to: "placements/edit_placement#update"
          end

          collection { get :check }

          collection do
            get "new", to: "placements/add_placement#new", as: :new_add_placement
            get "new/:step", to: "placements/add_placement#edit", as: :add_placement
            put "new/:step", to: "placements/add_placement#update"
          end
        end

        resources :partner_providers, only: %i[index show destroy] do
          member { get :remove }

          collection do
            get "new", to: "partner_providers/add_partner_provider#new", as: :new_add_partner_provider
            get "new/:step", to: "partner_providers/add_partner_provider#edit", as: :add_partner_provider
            put "new/:step", to: "partner_providers/add_partner_provider#update"
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

        resources :partner_schools, only: %i[index show destroy] do
          member { get :remove }

          collection do
            get "new", to: "partner_schools/add_partner_school#new", as: :new_add_partner_school
            get "new/:step", to: "partner_schools/add_partner_school#edit", as: :add_partner_school
            put "new/:step", to: "partner_schools/add_partner_school#update"
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

      resources :placements, only: %i[index show destroy] do
        member do
          get :remove
          get "edit", to: "placements/edit_placement#new", as: :new_edit_placement
          get "edit/:step", to: "placements/edit_placement#edit", as: :edit_placement
          put "edit/:step", to: "placements/edit_placement#update"
        end

        collection do
          get "new", to: "placements/add_placement#new", as: :new_add_placement
          get "new/:step", to: "placements/add_placement#edit", as: :add_placement
          put "new/:step", to: "placements/add_placement#update"
        end
      end

      resources :school_contacts, only: %i[edit update] do
        collection do
          get "new", to: "school_contacts/add_school_contact#new", as: :new_add_school_contact
          get "new/:step", to: "school_contacts/add_school_contact#edit", as: :add_school_contact
          put "new/:step", to: "school_contacts/add_school_contact#update"
        end
      end

      resources :partner_providers, only: %i[index show destroy] do
        member { get :remove }

        collection do
          get "new", to: "partner_providers/add_partner_provider#new", as: :new_add_partner_provider
          get "new/:step", to: "partner_providers/add_partner_provider#edit", as: :add_partner_provider
          put "new/:step", to: "partner_providers/add_partner_provider#update"
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

      resources :partner_schools, only: %i[index show destroy] do
        member { get :remove }

        collection do
          get "new", to: "partner_schools/add_partner_school#new", as: :new_add_partner_school
          get "new/:step", to: "partner_schools/add_partner_school#edit", as: :add_partner_school
          put "new/:step", to: "partner_schools/add_partner_school#update"
        end
      end
    end
  end

  resources :placements, only: %i[index show]
end
