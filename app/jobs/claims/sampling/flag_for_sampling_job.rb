class Claims::Sampling::FlagForSamplingJob < ApplicationJob
  queue_as :default

  def perform(claim)
    Claims::Claim::Sampling::InProgress.call(claim:)
  end
end
