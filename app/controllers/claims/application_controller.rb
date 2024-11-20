class Claims::ApplicationController < ApplicationController
  after_action :verify_authorized

  def authorize(record, query = nil, policy_class: nil)
    super([:claims, *unwrap_pundit_scope(record)], query, policy_class:)
  end

  def policy(record)
    super([:claims, *unwrap_pundit_scope(record)])
  end

  private

  def pundit_policy_scope(scope)
    super([:claims, *unwrap_pundit_scope(scope)])
  end

  def has_school_accepted_grant_conditions?
    return true if current_user.support_user?

    redirect_to claims_school_grant_conditions_path(@school) unless @school.grant_conditions_accepted?
  end
end
