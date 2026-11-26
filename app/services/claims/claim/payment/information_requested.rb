class Claims::Claim::Payment::InformationRequested < ApplicationService
  def initialize(claim:, unpaid_reason:)
    @claim = claim
    @unpaid_reason = unpaid_reason
  end

  def call
    Claims::Claim::ChangeStatus.call(claim:, attributes: { status: :payment_information_requested, unpaid_reason: })
  end

  private

  attr_reader :claim, :unpaid_reason
end
