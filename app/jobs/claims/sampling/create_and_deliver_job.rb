class Claims::Sampling::CreateAndDeliverJob < ApplicationJob
  queue_as :default

  def perform(current_user_id:, csv_data:)
    @current_user_id = current_user_id
    @csv_data = csv_data

    Claims::Sampling::CreateAndDeliver.call(current_user:, claims:, csv_data:)
  end

  private

  attr_reader :current_user_id, :csv_data

  def claim_ids
    @claim_ids ||= csv_data.map { |claim| claim[:id] }.compact
  end

  def claims
    @claims ||= Claims::Claim.where(id: claim_ids)
  end

  def current_user
    @current_user ||= User.find(current_user_id)
  end
end
