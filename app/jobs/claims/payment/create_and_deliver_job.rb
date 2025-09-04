class Claims::Payment::CreateAndDeliverJob < ApplicationJob
  queue_as :default

  def perform(current_user_id:, claim_window_id:)
    @current_user_id = current_user_id
    @claim_window_id = claim_window_id

    Claims::Payment::CreateAndDeliver.call(current_user:, claim_window:)
  end

  private

  attr_reader :current_user_id, :claim_window_id

  def claim_window
    @claim_window ||= Claims::ClaimWindow.find(claim_window_id)
  end

  def current_user
    @current_user ||= User.find(current_user_id)
  end
end
