class Claims::Claim::Payment::Paid < ApplicationService
  def initialize(claim:, paid_to_la: nil, date_paid: nil)
    @claim = claim
    @paid_to_la = paid_to_la
    @date_paid = date_paid
  end

  def call
    claim.update!(status: :paid, paid_to_la:, date_paid:)
  end

  private

  attr_reader :claim, :paid_to_la, :date_paid
end
