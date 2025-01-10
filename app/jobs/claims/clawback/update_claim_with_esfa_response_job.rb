class Claims::Clawback::UpdateClaimWithESFAResponseJob < ApplicationJob
  queue_as :default

  def perform(claim)
    Claims::Claim::Clawback::Complete.call(
      claim:,
    )
  end
end
