require "rails_helper"

RSpec.describe Claims::AddClaimWizard::MentorTrainingStep::DisclaimerComponent, type: :component do
  let(:mentor) { create(:claims_mentor) }
  let(:provider) { create(:claims_provider, :niot) }
  let(:training_allowance) do
    instance_double(Claims::TrainingAllowance).tap do |training_allowance|
      allow(training_allowance).to receive_messages(
        remaining_hours:,
        total_hours: 20,
      )
    end
  end
  let(:mentor_training_step) do
    instance_double(Claims::AddClaimWizard::MentorTrainingStep).tap do |mentor_training_step|
      allow(mentor_training_step).to receive_messages(
        training_allowance:,
        mentor:,
        provider:,
        mentor_full_name: mentor.full_name,
        provider_name: provider.name,
      )
    end
  end

  context "when mentor has no previous claims" do
    let(:remaining_hours) { 20 }

    it "does not render" do
      render_inline described_class.new(mentor_training_step:)

      expect(page).not_to have_css(".govuk-inset-text")
    end
  end

  context "when mentor has a previous claim of less than 20 hours" do
    let(:remaining_hours) { 6 }

    it "renders an inset text block with the remaining hours left for a mentor to claim for the selected provider" do
      render_inline described_class.new(mentor_training_step:)

      expect(page).to have_css(".govuk-inset-text")
      expect(page).to have_content "There are 6 hours left to claim for #{mentor.full_name} for #{provider.name}."
      expect(page).to have_content "Contact ittmentor.funding@education.gov.uk if you think there is a problem."
    end
  end
end
