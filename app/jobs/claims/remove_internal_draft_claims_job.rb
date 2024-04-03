class Claims::RemoveInternalDraftClaimsJob < ApplicationJob
  queue_as :default

  def perform
    Audited.audit_class.as_user("System") do
      Claims::Claim::RemoveInternalDrafts.call
    end
  end
end
