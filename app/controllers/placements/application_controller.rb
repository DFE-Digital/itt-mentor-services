class Placements::ApplicationController < ApplicationController
  after_action :verify_policy_scoped, only: %i[index]
  before_action :authorize_support_user!

  def current_user
    @current_user ||= sign_in_user&.user&.tap do |user|
      organisation_id = session.dig("current_organisation", "id")
      organisation_type = session.dig("current_organisation", "type")
      organisation = user.user_memberships.find_by(organisation_id:, organisation_type:)&.organisation

      user.current_organisation = case organisation
                                  when School
                                    organisation.becomes(Placements::School)
                                  when Provider
                                    organisation.becomes(Placements::Provider)
                                  end
    end
  end

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
