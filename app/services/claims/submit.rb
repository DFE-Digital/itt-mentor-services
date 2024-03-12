class Claims::Submit
  include ServicePattern

  def initialize(claim:, claim_params:)
    @claim = claim
    @claim_params = claim_params
  end

  def call
    updated_claim.save!
  end

  private

  attr_reader :claim, :claim_params

  def updated_claim
    @updated_claim ||= begin
      claim.assign_attributes(claim_params)
      claim.reference = generate_reference
      claim
    end
  end

  def generate_reference
    reference = SecureRandom.random_number(99_999_999) while Claim.exists?(reference:)
    reference
  end
end
