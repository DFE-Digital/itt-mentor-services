scope module: :claims, as: :claims, constraints: { host: ENV["CLAIMS_HOST"] } do
  root to: "pages#start"
  get :accessibility, to: "pages#accessibility"
  get :cookies, to: "pages#cookies"
  get :terms, to: "pages#terms"

  scope module: :pages do
    get :feedback
  end

  resources :schools, only: %i[index show] do
    scope module: :schools do
      resources :claims, except: %i[destroy] do
        resources :mentors, only: %i[new create edit update], module: :claims
        resources :mentor_trainings, only: %i[edit update], module: :claims

        member do
          get :check
          get :confirm
          post :submit
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

  namespace :support do
    root to: redirect("/support/schools")

    resources :claims, only: %i[index show] do
      get :download_csv, on: :collection
    end

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
        resources :claims do
          resources :mentors, only: %i[new create edit update], module: :claims
          resources :mentor_trainings, only: %i[edit update], module: :claims

          member do
            get :remove
            get :check
            post :submit
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
  end
end
