class Claims::Sampling::CreateAndDeliverJob < ApplicationJob
  queue_as :default

  def perform(current_user_id:, claim_ids:)
    @current_user_id = current_user_id
    @claim_ids = claim_ids

    Claims::Sampling::CreateAndDeliver.call(current_user:, claims:)
  end

  private

  attr_reader :current_user_id, :claim_ids

  def claims
    @claims ||= Claims::Claim.find(claim_ids)
  end

  def current_user
    @current_user ||= User.find(current_user_id)
  end
end
