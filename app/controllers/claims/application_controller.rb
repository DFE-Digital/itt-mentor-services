class Claims::ApplicationController < ApplicationController
  after_action :verify_authorized

  private

  def has_school_accepted_grant_conditions?
    return true if current_user.support_user?

    redirect_to claims_school_grant_conditions_path(@school) unless @school.grant_conditions_accepted?
  end
end
