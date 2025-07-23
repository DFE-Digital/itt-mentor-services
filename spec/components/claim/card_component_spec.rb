require "rails_helper"

RSpec.describe Claim::CardComponent, type: :component do
  include Rails.application.routes.url_helpers

  subject(:component) { described_class.new(claim:, href:, current_user:) }

  let(:claim) do
    create(:claim, :submitted, submitted_at: "2024/04/08", school:, support_user:) do |claim|
      claim.mentor_trainings << create(:mentor_training, hours_completed: 20)
    end
  end

  let(:href) { claims_support_claim_path(claim) }
  let(:school) { create(:claims_school, region: regions(:inner_london)) }
  let(:current_user) { create(:claims_user, schools: [school]) }
  let(:support_user) { create(:claims_support_user, first_name: "John", last_name: "Smith") }

  context "when current user is not a support user" do
    it "renders a card with claim details without support user details" do
      render_inline(component)

      expect(page).to have_link(claim.school_name, href: claims_support_claim_path(claim))
      expect(page).to have_content(claim.reference)
      expect(page).to have_content("Submitted")

      expect(page).to have_content(claim.academic_year_name)
      expect(page).to have_content(claim.provider_name)
      expect(page).to have_content("8 April 2024")
      expect(page).to have_content("£1,072.00")
      expect(page).not_to have_content("Support user: John Smith")
    end
  end

  context "when current user is a support user" do
    let(:current_user) { support_user }

    it "renders a card with claim details with support user details" do
      render_inline(component)

      expect(page).to have_link(claim.school_name, href: claims_support_claim_path(claim))
      expect(page).to have_content(claim.reference)
      expect(page).to have_content("Submitted")

      expect(page).to have_content(claim.academic_year_name)
      expect(page).to have_content(claim.provider_name)
      expect(page).to have_content("8 April 2024")
      expect(page).to have_content("£1,072.00")
      expect(page).to have_content("Support user: John Smith")
    end
  end
end
