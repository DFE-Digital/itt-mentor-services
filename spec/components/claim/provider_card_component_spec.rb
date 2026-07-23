require "rails_helper"

RSpec.describe Claim::ProviderCardComponent, type: :component do
  subject(:component) { described_class.new(claim:, href:, current_user:) }

  let(:school) do
    create(
      :claims_school,
      region: regions(:inner_london),
      address1: "1 High Street",
      town: "London",
      postcode: "SW1A 1AA",
    )
  end
  let(:support_user) { create(:claims_support_user, first_name: "John", last_name: "Smith") }
  let(:claim) do
    create(
      :claim,
      :submitted,
      status:,
      submitted_at: "2024/04/08",
      created_at: "2024/04/08",
      school:,
      support_user:,
    ) do |claim|
      claim.mentor_trainings << create(:mentor_training, hours_completed: 20)
    end
  end
  let(:href) { "/claims/#{claim.id}" }
  let(:current_user) { create(:claims_user) }
  let(:status) { :sampling_provider_not_approved }

  it "renders the provider claim card content" do
    render_inline(component)

    expect(page).to have_content("#{claim.school_urn},")
    expect(page).to have_link(claim.school_name, href:)
    expect(page).to have_content("Amended")
    expect(page).to have_content("1 High Street")
    expect(page).to have_content("Date submitted: 8 April 2024")
    expect(page).to have_content("Claim reference: #{claim.reference}")
    expect(page).to have_content("£1,072.00")
  end

  context "when the claim has been approved" do
    let(:status) { :paid }

    it "renders the provider status text as approved" do
      render_inline(component)

      expect(page).to have_content("Approved")
    end
  end
end
