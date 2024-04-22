require "rails_helper"

RSpec.describe Claims::Claim::MentorTrainingForm::DisclaimerComponent, type: :component do
  let(:mentor_training_form) { Claims::Claim::MentorTrainingForm.new(claim:, mentor_training:) }

  let(:claim) { create(:claim) }
  let(:mentor_training) { create(:mentor_training) }

  context "when mentor has no previous claims" do
    it "does not render" do
      render_inline described_class.new(mentor_training_form:)

      expect(page).not_to have_css(".govuk-inset-text")
    end
  end

  context "when mentor has a previous claim of less than 20 hours" do
    before do
      create(:mentor_training, :submitted, mentor: mentor_training.mentor, provider: mentor_training.provider, hours_completed: 10)
    end

    it "renders an inset text block with the remaining hours left for a mentor to claim for the selected provider" do
      render_inline described_class.new(mentor_training_form:)

      expect(page).to have_css(".govuk-inset-text")
      expect(page).to have_content "There are 10 hours left to claim for #{mentor_training.mentor.full_name} for #{mentor_training.provider.name}."
      expect(page).to have_content "Contact ittmentor.funding@education.gov.uk if you think there is a problem."
    end
  end
end
