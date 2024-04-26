Flipflop.configure do
  strategy :active_record
  strategy :default

  feature :test_feature, description: "This is a test feature"

  group :placements do
    feature :placements_user_onboarding_emails,
            description: "Dispatch emails to users when they have been" \
            " onboarded onto the placements service",
            default: false
  end
end
