require "rails_helper"

RSpec.describe Claims::AddClaimWizard::MentorStep::DisclaimerComponent, type: :component do
  let(:provider) { create(:claims_provider) }
  let(:claim) { create(:claim, provider:) }
  let(:mentor_step) do
    instance_double(Claims::AddClaimWizard::MentorStep).tap do |mentor_step|
      allow(mentor_step).to receive_messages(
        claim:,
        all_school_mentors_visible?: all_school_mentors_visible,
      )
    end
  end

  context "when all mentors have no previous claims" do
    let(:all_school_mentors_visible) { true }

    it "does not render" do
      render_inline described_class.new(mentor_step:)

      expect(page).not_to have_css(".govuk-inset-text")
    end
  end

  context "when a mentor has a previous claim of all 20 hours" do
    let(:all_school_mentors_visible) { false }

    it "renders a details block with information about why a mentor is missing from the list" do
      render_inline described_class.new(mentor_step:)

      expect(page).to have_css(".govuk-details")
      expect(page).to have_content "If a mentor you have added is not showing in the list, they have already claimed 20 hours with #{claim.provider_name}."
      expect(page).to have_content "If you think this is a mistake, contact ittmentor.funding@education.gov.uk."
    end
  end
end
