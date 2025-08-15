class Claims::Claim::Clawback::ClawbackRequested < ApplicationService
  def initialize(claim:, current_user:, esfa_responses: [])
    @claim = claim
    @esfa_responses = esfa_responses
    @current_user = current_user
  end

  def call
    claim.transaction do
      claim.mentor_trainings.each do |mentor_training|
        esfa_mentor_training_response = esfa_responses.find { |response| response[:id] == mentor_training.id }
        next if esfa_mentor_training_response.blank?

        mentor_training.update!(
          hours_clawed_back: esfa_mentor_training_response[:hours_clawed_back],
          reason_clawed_back: esfa_mentor_training_response[:reason_for_clawback],
        )
      end

      # claim.update!(status: :clawback_requested)
      claim.update!(
        status: :clawback_requires_approval,
        clawback_requested_by: current_user,
      )
    end
  end

  private

  attr_reader :claim, :esfa_responses, :current_user
end
