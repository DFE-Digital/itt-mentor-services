class Claims::Submit
  include ServicePattern

  def initialize(claim:, draft:)
    @claim = claim
    @draft = draft
  end

  def call
    updated_claim.save!
  end

  private

  attr_reader :claim, :draft

  def updated_claim
    @updated_claim ||= begin
      claim.draft = draft
      claim.submitted_at = Time.current
      claim.reference = generate_reference
      claim
    end
  end

  def generate_reference
    reference = SecureRandom.random_number(99_999_999) while Claim.exists?(reference:)
    reference
  end
end
