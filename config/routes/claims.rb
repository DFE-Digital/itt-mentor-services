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
  end
end
