class Placements::ApplicationController < ApplicationController
  after_action :verify_policy_scoped, if: ->(c) { c.action_name == "index" }
  before_action :authorize_support_user!

  private

  def set_school
    @school = if current_user.support_user?
                Placements::School.find(params.require(:school_id))
              else
                current_user.schools.find(params.require(:school_id))
              end
  end

  def set_provider
    @provider = if current_user.support_user?
                  Placements::Provider.find(params.require(:provider_id))
                else
                  current_user.providers.find(params.require(:provider_id))
                end
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
