require "rails_helper"

RSpec.describe Claim::ProviderStatusTagComponent, type: :component do
  it "renders the provider-specific status text for amended claims" do
    claim = create(:claim, :submitted, status: :sampling_provider_not_approved)

    render_inline(described_class.new(claim:))

    expect(page).to have_content("Amended")
  end

  it "renders the provider-specific status text for approved claims" do
    claim = create(:claim, :submitted, status: :paid)

    render_inline(described_class.new(claim:))

    expect(page).to have_content("Approved")
  end

  it "renders the audit requested status text" do
    claim = create(:claim, :audit_requested)

    render_inline(described_class.new(claim:))

    expect(page).to have_content("Audit requested")
  end
end
