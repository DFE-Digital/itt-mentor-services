scope module: :placements,
      as: :placements,
      constraints: {
        host: ENV["PLACEMENTS_HOST"]
      } do
  root to: "pages#index"

  namespace :support do
    root to: redirect("/support/organisations")
    resources :organisations, only: :index
  end
end
