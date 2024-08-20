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

  namespace :payments do
    resources :claims, only: [] do
      get :download, on: :collection
    end
  end

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

      resources :mentors, only: %i[index new create show destroy] do
        member { get :remove }
        collection { get :check }
      end

      resources :users, only: %i[index new create show destroy] do
        get :check, on: :collection
        get :remove, on: :member
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

    namespace :claims do
      resources :activity_logs, only: %i[index show]

      namespace :payments do
        resources :confirmations, only: %i[new create]
        resources :claims, only: %i[show] do
          member do
            get :check_information_sent, path: "information-sent"
            put :information_sent, path: "information-sent"
            get :check_reject, path: "reject"
            put :reject
          end
        end
      end

      resources :payments, only: %i[index new create]
    end

    resources :claims, only: %i[index show] do
      get :download_csv, on: :collection
    end

    resources :support_users, path: "support-users" do
      get :check, on: :collection
      get :remove, on: :member
    end

    resources :schools, except: %i[destroy update] do
      member do
        put :remove_grant_conditions_acceptance, path: "remove-grant-conditions-acceptance"
        get :remove_grant_conditions_acceptance_check, path: "remove-grant-conditions-acceptance"
      end

      collection do
        get :check
        get :check_school_option
        get :school_options
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

        resources :users, only: %i[index new create show destroy] do
          get :check, on: :collection
          get :remove, on: :member
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
