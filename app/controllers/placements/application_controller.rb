class Placements::ApplicationController < ApplicationController
  before_action :authorize_support_user!

  private

  def authorize_support_user!
    user_not_authorized if support_controller? && !current_user.support_user?
  end

  def support_controller?
    self.class.name.start_with? "Placements::Support::"
  end
end
