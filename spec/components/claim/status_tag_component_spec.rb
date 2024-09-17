require "rails_helper"

RSpec.describe Claim::StatusTagComponent, type: :component do
  subject(:component) { described_class.new(claim:) }

  before do
    render_inline(component)
  end

  context "when the claim's status is 'draft'" do
    let(:claim) { build(:claim, status: :draft) }

    it "renders a grey tag" do
      expect(page).to have_css(".govuk-tag--grey", text: "Draft")
    end
  end

  context "when the claim's status is 'submitted'" do
    let(:claim) { build(:claim, status: :submitted) }

    it "renders a blue tag" do
      expect(page).to have_css(".govuk-tag--blue", text: "Submitted")
    end
  end

  context "when the claim's status is 'sent_to_esfa'" do
    let(:claim) { build(:claim, status: :sent_to_esfa) }

    it "renders a light blue tag" do
      expect(page).to have_css(".govuk-tag--light-blue", text: "Sent to ESFA")
    end
  end

  Claims::Claim.statuses.each_key do |status|
    context "with a claim of status '#{status}'" do
      let(:claim) { build(:claim, status:) }

      it "renders successfully" do
        expect(page).to have_css(".govuk-tag")
      end
    end
  end
end
