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

    resources :schools, expect: %i[edit update] do
      collection { get :check }
    end
    resources :providers, expect: %i[edit update] do
      collection { get :check }
    end
    resources :provider_suggestions, only: [:index]
    resources :schools, only: [:show]
  end

  resources :organisations, only: [:index]
end
