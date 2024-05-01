class Claims::Claim::Reviewed
  include ServicePattern

  def initialize(claim:)
    @claim = claim
  end

  def call
    claim.update!(reviewed: true)
  end

  private

  attr_reader :claim
end
