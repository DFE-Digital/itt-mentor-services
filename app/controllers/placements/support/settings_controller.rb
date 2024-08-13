class Placements::Support::SettingsController < Placements::ApplicationController
  skip_after_action :verify_policy_scoped
end
