class Claims::Claim::Sampling::ProviderNotApproved < ApplicationService
  def initialize(claim:, provider_responses: [])
    @claim = claim
    @provider_responses = provider_responses
  end

  def call
    claim.transaction do
      claim.mentor_trainings.each do |mentor_training|
        mentor_training_provider_response = provider_responses.find do |provider_response|
          provider_response[:id] == mentor_training.id
        end
        next if mentor_training_provider_response.blank?

        mentor_training.update!(
          not_assured: mentor_training_provider_response[:not_assured],
          reason_not_assured: mentor_training_provider_response[:reason_not_assured],
        )
      end
      claim.update!(
        status: :sampling_provider_not_approved,
      )
    end
  end

  private

  attr_reader :claim, :provider_responses
end
