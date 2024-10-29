class Claims::Claim::MentorTrainingForm::DisclaimerComponentPreview < ApplicationComponentPreview
  def default
    school = FactoryBot.build(
      :claims_school,
      id: SecureRandom.uuid,
      mentors: [FactoryBot.build(:claims_mentor)],
    )
    claim = FactoryBot.build(:claim, :submitted, school:)
    mentor_training = FactoryBot.build(:mentor_training, claim:)
    mentor_training_form = PreviewMentorTrainingForm.new(claim:, mentor_training:)

    render Claims::Claim::MentorTrainingForm::DisclaimerComponent.new(mentor_training_form:)
  end

  class PreviewMentorTrainingForm < Claims::Claim::MentorTrainingForm
    def training_allowance
      PreviewClaimsTrainingAllowance.new(
        mentor: FactoryBot.build(:claims_mentor), 
        provider: FactoryBot.build(:claims_provider),
        academic_year: FactoryBot.build(:academic_year, :current),
      )
    end
  end

  class PreviewClaimsTrainingAllowance < Claims::TrainingAllowance
    def remaining_hours
      rand(1..19)
    end
  end
end
