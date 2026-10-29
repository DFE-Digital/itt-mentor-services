class Claims::Claim::Sampling::Paid < ApplicationService
  def initialize(claim:)
    @claim = claim
  end

  def call
    Claims::Claim::ChangeStatus.call(claim:, attributes: { status: :paid })
  end

  private

  attr_reader :claim
end
