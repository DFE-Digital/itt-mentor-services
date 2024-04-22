class Claims::Claim::MentorTrainingForm::DisclaimerComponentPreview < ApplicationComponentPreview
  def default
    render Claims::Claim::MentorTrainingForm::DisclaimerComponent.new(mentor_training_form:)
  end

  private

  def mentor_training_form
    Claims::Claim::MentorTrainingForm.new(claim:, mentor_training:)
  end

  def claim
    Claims::Claim.where.associated(:mentor_trainings).first
  end

  def mentor_training
    claim.mentor_trainings.first
  end
end
