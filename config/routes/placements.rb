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
    end

    resources :schools, expect: %i[edit update show] do
      collection do
        get :check
        get :check_school_option
        get :school_options
      end

      scope module: :schools do
        resources :users, only: %i[index new create show] do
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
        resources :users, only: %i[index new create show] do
          collection { get :check }
        end
      end
    end
  end
end
