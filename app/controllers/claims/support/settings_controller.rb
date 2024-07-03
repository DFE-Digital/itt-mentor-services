class Claims::Support::SettingsController < Claims::Support::ApplicationController
  before_action :skip_authorization
end
