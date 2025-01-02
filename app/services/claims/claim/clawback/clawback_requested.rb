class Claims::Claim::Clawback::ClawbackRequested < ApplicationService
  def initialize(claim:, esfa_responses: [])
    @claim = claim
    @esfa_responses = esfa_responses
  end

  def call
    claim.transaction do
      claim.mentor_trainings.each do |mentor_training|
        esfa_mentor_training_response = esfa_responses.find { |response| response[:id] == mentor_training.id }
        next if esfa_mentor_training_response.blank?

        mentor_training.update!(
          hours_clawed_back: esfa_mentor_training_response[:number_of_hours],
          reason_clawed_back: esfa_mentor_training_response[:reason_for_clawback],
        )
      end

      claim.update!(status: :clawback_requested)
    end
  end

  private

  attr_reader :claim, :esfa_responses
end
