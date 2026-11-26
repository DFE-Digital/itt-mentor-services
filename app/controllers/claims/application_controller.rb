class Claims::ApplicationController < ApplicationController
  append_pundit_namespace :claims

  after_action :verify_authorized
  around_action :with_claim_audit_actor

  # DFE Analytics namespace
  def current_namespace
    "claims"
  end

  private

  def with_claim_audit_actor(&block)
    Claims::AuditContext.set(actor: current_user, &block)
  end

  def has_school_accepted_grant_conditions?
    return true if current_user.support_user?

    redirect_to claims_school_grant_conditions_path(@school) unless @school.grant_conditions_accepted?
  end
end
