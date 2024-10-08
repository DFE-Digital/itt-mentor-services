class Placements::ApplicationController < ApplicationController
  after_action :verify_policy_scoped, if: ->(c) { c.action_name == "index" }
  before_action :authorize_support_user!

  private

  def set_school
    @school = policy_scope(Placements::School).find(params.require(:school_id))
  end

  def set_provider
    @provider = policy_scope(Placements::Provider).find(params.require(:provider_id))
  end

  def authorize_support_user!
    user_not_authorized if support_controller? && !current_user.support_user?
  end

  def support_controller?
    @support_controller ||= self.class.name.start_with? "Placements::Support::"
  end

  def restricted_placements_controller?
    # All users should be able to access routes to the PagesController
    !instance_of?(::Placements::PagesController)
  end
end
