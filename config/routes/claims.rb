scope module: :claims, as: :claims, constraints: {
  host: [ENV["CLAIMS_HOST"], *ENV.fetch("CLAIMS_HOSTS", "").split(",")],
} do
  root to: "pages#start"

  scope module: :pages do
    get :accessibility
    get :cookies
    get :terms
    get :privacy
    get :grant_conditions, path: "grant-conditions"
  end

  resources :service_updates, path: "service-updates", only: %i[index show]

  resources :schools, only: %i[index show] do
    scope module: :schools do
      resources :claims do
        resource :mentors, only: %i[new create edit update], module: :claims do
          member do
            get :create_revision
          end
        end
        resources :mentor_trainings, only: %i[edit update], module: :claims do
          member do
            get :create_revision
          end
        end

        member do
          get :remove
          get :check
          get :confirmation
          get :rejected
          get :create_revision
          post :submit
        end
      end

      resource :grant_conditions, only: %i[show update]

      resources :mentors, only: %i[index show destroy] do
        member { get :remove }

        collection do
          get "new", to: "mentors/add_mentor#new", as: :new_add_mentor
          get "new/:state_key/:step", to: "mentors/add_mentor#edit", as: :add_mentor
          put "new/:state_key/:step", to: "mentors/add_mentor#update"
        end
      end

      resources :users, only: %i[index show destroy] do
        get :remove, on: :member

        collection do
          get "new", to: "users/add_user#new", as: :new_add_user
          get "new/:state_key/:step", to: "users/add_user#edit", as: :add_user
          put "new/:state_key/:step", to: "users/add_user#update"
        end
      end
    end
  end

  namespace :support do
    root to: redirect("/support/schools")

    unless HostingEnvironment.env.production?
      resource :database, only: %i[destroy] do
        get :reset
      end
    end

    resources :claims, only: %i[index show] do
      get :download_csv, on: :collection
    end

    resources :support_users, path: "support-users", only: %i[index show destroy] do
      get :remove, on: :member

      collection do
        get "new", to: "support_users/add_support_user#new", as: :new_add_support_user
        get "new/:state_key/:step", to: "support_users/add_support_user#edit", as: :add_support_user
        put "new/:state_key/:step", to: "support_users/add_support_user#update"
      end
    end

    resources :schools, only: %i[index show] do
      member do
        put :remove_grant_conditions_acceptance, path: "remove-grant-conditions-acceptance"
        get :remove_grant_conditions_acceptance_check, path: "remove-grant-conditions-acceptance"
      end

      collection do
        get "new", to: "schools/add_school#new", as: :new_add_school
        get "new/:state_key/:step", to: "schools/add_school#edit", as: :add_school
        put "new/:state_key/:step", to: "schools/add_school#update"
      end

      scope module: :schools do
        resources :claims do
          resource :mentors, only: %i[new create edit update], module: :claims do
            member do
              get :create_revision
            end
          end
          resources :mentor_trainings, only: %i[edit update], module: :claims do
            member do
              get :create_revision
            end
          end

          member do
            get :remove
            get :check
            get :rejected
            post :draft
            get :create_revision
          end
        end

        resources :mentors, only: %i[index new create show destroy] do
          member { get :remove }
          collection { get :check }
        end

        resources :users, only: %i[index show destroy] do
          get :remove, on: :member

          collection do
            get "new", to: "users/add_user#new", as: :new_add_user
            get "new/:state_key/:step", to: "users/add_user#edit", as: :add_user
            put "new/:state_key/:step", to: "users/add_user#update"
          end
        end
      end
    end

    get :settings, to: "settings#index"

    resources :mailers, only: :index

    resources :claim_windows do
      get :new_check, path: :check, on: :collection
      get :edit_check, path: :check, on: :member
      get :remove, on: :member
    end
  end
end
