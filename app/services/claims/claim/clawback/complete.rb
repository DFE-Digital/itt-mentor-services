class Claims::Claim::Clawback::Complete < ApplicationService
  def initialize(claim:)
    @claim = claim
  end

  def call
    Claims::Claim::ChangeStatus.call(claim:, attributes: { status: :clawback_complete })
  end

  private

  attr_reader :claim
end
