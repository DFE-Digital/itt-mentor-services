class Claims::Claim::Sampling::NotApproved < ApplicationService
  def initialize(claim:, school_responses: [])
    @claim = claim
    @school_responses = school_responses
  end

  def call
    claim.transaction do
      claim.mentor_trainings.not_assured.each do |mentor_training|
        mentor_training_school_response = school_responses.find do |school_response|
          school_response[:id] == mentor_training.id
        end
        next if mentor_training_school_response.blank?

        mentor_training.update!(
          rejected: mentor_training_school_response[:rejected],
          reason_rejected: mentor_training_school_response[:reason_rejected],
        )
      end
      claim.update!(status: :sampling_not_approved)
    end
  end

  private

  attr_reader :claim, :school_responses
end
