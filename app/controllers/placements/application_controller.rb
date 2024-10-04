class Placements::ApplicationController < ApplicationController
  after_action :verify_policy_scoped, if: ->(c) { c.action_name == "index" }
  before_action :authorize_support_user!

  private

  def authorize_support_user!
    user_not_authorized if (support_controller? && !current_user.support_user?) ||
      (!support_controller? && restricted_placements_controller? && current_user.support_user?)
  end

  def support_controller?
    @support_controller ||= self.class.name.start_with? "Placements::Support::"
  end

  def restricted_placements_controller?
    # All users should be able to access routes to the PagesController
    !instance_of?(::Placements::PagesController)
  end
end
