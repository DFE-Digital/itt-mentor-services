class Claims::Claim::CreateRevision
  include ServicePattern

  def initialize(claim:)
    @claim = claim
  end

  def call
    revision_record = deep_dup
    revision_record.save!

    revision_record
  end

  private

  attr_reader :claim

  def deep_dup
    dup_record = claim.dup
    dup_record.mentor_trainings = claim.mentor_trainings.map(&:dup)
    dup_record.previous_revision_id = claim.id
    dup_record.status = :internal_draft
    dup_record
  end
end
