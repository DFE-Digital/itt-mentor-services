class Claims::Claim::Clawback::Complete < ApplicationService
  def initialize(claim:, esfa_responses: [])
    @claim = claim
    @esfa_responses = esfa_responses
  end

  def call
    claim.transaction do
      claim.mentor_trainings.not_assured.each do |mentor_training|
        esfa_mentor_training_response = esfa_responses.find do |esfa_response|
          esfa_response[:id] == mentor_training.id
        end
        next if esfa_mentor_training_response.blank?

        mentor_training.update!(
          hours_clawed_back: esfa_mentor_training_response[:hours_clawed_back],
          reason_clawed_back: esfa_mentor_training_response[:reason_clawed_back],
        )
      end

      claim.update!(status: :clawback_complete)
    end
  end

  private

  attr_reader :claim, :esfa_responses
end
