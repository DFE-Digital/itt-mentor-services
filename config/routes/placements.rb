scope module: :placements, as: :placements, constraints: { host: ENV["PLACEMENTS_HOST"] } do
  root to: "pages#index"
end
