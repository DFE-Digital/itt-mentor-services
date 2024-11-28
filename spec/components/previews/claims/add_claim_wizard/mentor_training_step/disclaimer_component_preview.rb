class Claims::AddClaimWizard::MentorTrainingStep::DisclaimerComponentPreview < ApplicationComponentPreview
  def default
    school = FactoryBot.build_stubbed(:claims_school)
    user = FactoryBot.build_stubbed(:claims_user)
    wizard = PreviewAddClaimWizard.new(
      school:,
      created_by: user,
      params: {},
      state: {},
      current_step: nil,
    )

    render Claims::AddClaimWizard::MentorTrainingStep::DisclaimerComponent.new(
      mentor_training_step: PreviewMentorTrainingStep.new(
        wizard:,
        attributes: { mentor_id: wizard.mentors_with_claimable_hours.first.id },
      ),
    )
  end

  class PreviewAddClaimWizard < Claims::AddClaimWizard
    def provider
      FactoryBot.build_stubbed(:claims_provider, :niot)
    end

    def mentors_with_claimable_hours
      [FactoryBot.build_stubbed(:claims_mentor)]
    end
  end

  class PreviewMentorTrainingStep < Claims::AddClaimWizard::MentorTrainingStep
    def mentor
      wizard.mentors_with_claimable_hours.first
    end

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
