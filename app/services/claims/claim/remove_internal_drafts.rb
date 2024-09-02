class Claims::Claim::RemoveInternalDrafts < ApplicationService
  def call
    Claims::Claim.internal_draft.where(updated_at: ..1.day.ago).destroy_all
  end
end
