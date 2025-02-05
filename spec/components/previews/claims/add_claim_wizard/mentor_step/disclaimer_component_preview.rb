class Claims::AddClaimWizard::MentorStep::DisclaimerComponentPreview < ApplicationComponentPreview
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
    mentor_step = PreviewMentorStep.new(wizard:, attributes: {})

    render Claims::AddClaimWizard::MentorStep::DisclaimerComponent.new(mentor_step:)
  end

  class PreviewMentorStep < Claims::AddClaimWizard::MentorStep
    def all_school_mentors_visible?
      false
    end
  end

  class PreviewAddClaimWizard < Claims::AddClaimWizard
    def claim
      Claims::Claim.new(provider: FactoryBot.build_stubbed(:claims_provider, :niot))
    end
  end
end
