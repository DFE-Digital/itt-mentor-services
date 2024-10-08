class Claims::Claim::UpdateDraft < ApplicationService
  def initialize(claim:)
    @claim = claim
  end

  def call
    ActiveRecord::Base.transaction do
      updated_claim.save!
      update_previous_revisions_to_internal_draft
    end
  end

  private

  attr_reader :claim

  def update_previous_revisions_to_internal_draft
    claim_record = updated_claim.previous_revision

    while claim_record.present?
      claim_record.update!(status: :internal_draft) if claim_record.draft?
      claim_record = claim_record.previous_revision
    end
  end

  def updated_claim
    @updated_claim ||= begin
      claim.status = :draft
      claim
    end
  end
end
