class Claims::Claim::Clawback::ClawbackNotRequired < ApplicationService
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
          hours_clawed_back: nil,
          reason_clawed_back: nil,
          rejected: false,
          reason_rejected: nil,
          not_assured: false,
          reason_not_assured: nil,
        )
      end

      claim.update!(
        status: :paid,
        clawback_requested_by: nil,
      )
    end
  end

  private

  attr_reader :claim, :esfa_responses
end
