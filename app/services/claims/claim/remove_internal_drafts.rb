class Claims::Claim::RemoveInternalDrafts
  include ServicePattern

  def call
    Claims::Claim.internal_draft.where(updated_at: ..1.day.ago).destroy_all
  end
end
