scope module: :placements,
      as: :placements,
      constraints: {
        host: ENV["PLACEMENTS_HOST"],
      } do
  root to: "pages#index"

  namespace :support do
    root to: redirect("/support/organisations")
    resources :organisations, only: %i[index new] do
      collection { get :select_type }
      scope module: :organisations do
        resources :users, only: %i[index new create show] do
          collection { get :check }
        end
      end
    end

    resources :schools, expect: %i[edit update] do
      collection do
        get :check
        get :check_school_option
        get :school_options
      end
    end
    resources :providers, expect: %i[edit update] do
      collection { get :check }
    end
    resources :provider_suggestions, only: [:index]
    resources :schools, only: [:show]
  end

  resources :organisations, only: [:index]
end
