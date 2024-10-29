class Claims::Claim::MentorsForm::DisclaimerComponentPreview < ApplicationComponentPreview
  def default
    school = FactoryBot.build_stubbed(
      :claims_school,
      mentors: [FactoryBot.build(:claims_mentor)],
    )
    claim = FactoryBot.build(:claim, :submitted, school:)

    mentors_form = PreviewMentorsForm.new(claim:)

    render Claims::Claim::MentorsForm::DisclaimerComponent.new(mentors_form:)
  end

  class PreviewMentorsForm < Claims::Claim::MentorsForm
    def all_school_mentors_visible?
      false
    end
  end
end
