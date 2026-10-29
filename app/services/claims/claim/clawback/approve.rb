class Claims::Claim::Clawback::Approve < ApplicationService
  def initialize(claim:, current_user:)
    @claim = claim
    @current_user = current_user
  end

  def call
    Claims::Claim::ChangeStatus.call(claim:, attributes: { status: :clawback_requested, clawback_approved_by: current_user }, actor: current_user)
  end

  private

  attr_reader :claim, :current_user
end
