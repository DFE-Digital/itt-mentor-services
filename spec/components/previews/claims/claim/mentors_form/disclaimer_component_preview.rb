class Claims::Claim::MentorsForm::DisclaimerComponentPreview < ApplicationComponentPreview
  def default
    render Claims::Claim::MentorsForm::DisclaimerComponent.new(mentors_form:)
  end

  private

  def mentors_form
    Claims::Claim::MentorsForm.new(claim:)
  end

  def claim
    Claims::Claim.first
  end
end
