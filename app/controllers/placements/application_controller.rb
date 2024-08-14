class Placements::ApplicationController < ApplicationController
  include Pundit::Authorization
  after_action :verify_policy_scoped, only: %i[index]
  before_action :authorize_support_user!

  def current_user
    @current_user ||= sign_in_user&.user&.tap do |user|
      organisation_id = session.dig("current_organisation", :id)
      organisation_type = session.dig("current_organisation", :type)
      current_org = user.user_memberships.find_by(organisation_id:, organisation_type:)&.organisation
      return user unless current_org

      user.current_organisation = current_org.is_a?(School) ? current_org.becomes(Placements::School) : current_org.becomes(Placements::Provider)
      user
    end
  end

  private

  def authorize_support_user!
    user_not_authorized if support_controller? && !current_user.support_user?
  end

  def support_controller?
    self.class.name.start_with? "Placements::Support::"
  end
end
