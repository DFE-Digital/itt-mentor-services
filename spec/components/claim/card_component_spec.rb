require "rails_helper"

RSpec.describe Claim::CardComponent, type: :component do
  include Rails.application.routes.url_helpers

  subject(:component) { described_class.new(claim:) }

  let(:claim) do
    create(:claim, :submitted, submitted_at: "2024/04/08", school:) do |claim|
      claim.mentor_trainings << create(:mentor_training, hours_completed: 20)
    end
  end

  let(:school) { create(:claims_school, region: regions(:inner_london)) }

  it "renders a card with claim details" do
    render_inline(component)

    expect(page).to have_link(claim.school.name, href: claims_support_claim_path(claim))
    expect(page).to have_content(claim.reference)
    expect(page).to have_content("Submitted")

    expect(page).to have_content(claim.academic_year_name)
    expect(page).to have_content(claim.provider.name)
    expect(page).to have_content("8 April 2024")
    expect(page).to have_content("£1,072.00")
  end
end
