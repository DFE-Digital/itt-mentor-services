require "rails_helper"

RSpec.describe Claims::Claim::MentorsForm::DisclaimerComponent, type: :component do
  let(:mentors_form) { Claims::Claim::MentorsForm.new(claim:) }

  let(:school) { create(:claims_school) }
  let(:claim) { create(:claim, school:) }

  before do
    school.mentors << create(:claims_mentor)
    school.mentors << create(:claims_mentor)
  end

  context "when all mentors have no previous claims" do
    it "does not render" do
      render_inline described_class.new(mentors_form:)

      expect(page).not_to have_css(".govuk-inset-text")
    end
  end

  context "when a mentor has a previous claim of all 20 hours" do
    before do
      create(:mentor_training, claim: create(:claim, :submitted, school:), mentor: school.mentors.first, provider: claim.provider, hours_completed: 20)
    end

    it "renders an inset text block with information about why a mentor is missing from the list" do
      render_inline described_class.new(mentors_form:)

      expect(page).to have_css(".govuk-inset-text")
      expect(page).to have_content "This list includes all mentors who can be included on a claim. If a mentor you have added is not showing in this list, that is because they have already had 20 hours of training claimed for with #{claim.provider.name}."
      expect(page).to have_content "Contact ittmentor.funding@education.gov.uk if you think there is a problem."
    end
  end
end
