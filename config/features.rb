Flipflop.configure do
  # Strategies will be used in the order listed here.
  strategy :redis
  strategy :default

  # Declare your features
  group :claims do
    feature :claims_test
  end

  group :placements do
    feature :placements_test, description: "Shiny feature", default: true
  end
end
