Flipflop.configure do
  strategy :active_record
  strategy :default

  feature :test_feature, description: "This is a test feature"
end
