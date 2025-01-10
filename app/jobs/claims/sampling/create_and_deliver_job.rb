class Claims::Sampling::CreateAndDeliverJob < ApplicationJob
  queue_as :default

  def perform(current_user_id:, claim_ids:, csv_data:)
    @current_user_id = current_user_id
    @claim_ids = claim_ids
    @csv_data = csv_data

    Claims::Sampling::CreateAndDeliver.call(current_user:, claims:, csv_data:)
  end

  private

  attr_reader :current_user_id, :claim_ids, :csv_data

  def claims
    @claims ||= Claims::Claim.find(claim_ids)
  end

  def current_user
    @current_user ||= User.find(current_user_id)
  end
end
