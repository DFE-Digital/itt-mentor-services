require "rails_helper"

RSpec.describe Claim::StatusTagComponent, type: :component do
  subject(:component) { described_class.new(claim:) }

  before do
    render_inline(component)
  end

  context "when the claim's status is 'internal_draft'" do
    let(:claim) { build(:claim, status: :internal_draft) }

    it "renders a grey tag" do
      expect(page).to have_css(".govuk-tag--grey", text: "Internal draft")
    end
  end

  context "when the claim's status is 'draft'" do
    let(:claim) { build(:claim, status: :draft) }

    it "renders a yellow tag" do
      expect(page).to have_css(".govuk-tag--yellow", text: "Draft")
    end
  end

  context "when the claim's status is 'submitted'" do
    let(:claim) { build(:claim, status: :submitted) }

    it "renders a turquoise tag" do
      expect(page).to have_css(".govuk-tag--turquoise", text: "Submitted")
    end
  end

  context "when the claim's status is 'payment_in_progress'" do
    let(:claim) { build(:claim, status: :payment_in_progress) }

    it "renders a yellow tag" do
      expect(page).to have_css(".govuk-tag--yellow", text: "Payer payment review")
    end
  end

  context "when the claim's status is 'payment_information_requested'" do
    let(:claim) { build(:claim, status: :payment_information_requested) }

    it "renders a turquoise tag" do
      expect(page).to have_css(".govuk-tag--turquoise", text: "Payer needs information")
    end
  end

  context "when the claim's status is 'payment_information_sent'" do
    let(:claim) { build(:claim, status: :payment_information_sent) }

    it "renders a yellow tag" do
      expect(page).to have_css(".govuk-tag--yellow", text: "Information sent to payer")
    end
  end

  context "when the claim's status is 'paid'" do
    let(:claim) { build(:claim, status: :paid) }

    it "renders a blue tag" do
      expect(page).to have_css(".govuk-tag--blue", text: "Paid")
    end
  end

  context "when the claim's status is 'payment_not_approved'" do
    let(:claim) { build(:claim, status: :payment_not_approved) }

    it "renders a orange tag" do
      expect(page).to have_css(".govuk-tag--orange", text: "Rejected by payer")
    end
  end

  context "when the claim's status is 'sampling_in_progress'" do
    let(:claim) { build(:claim, status: :sampling_in_progress) }

    it "renders a yellow tag" do
      expect(page).to have_css(".govuk-tag--yellow", text: "Audit requested")
    end
  end

  context "when the claim's status is 'sampling_provider_not_approved'" do
    let(:claim) { build(:claim, status: :sampling_provider_not_approved) }

    it "renders a turquoise tag" do
      expect(page).to have_css(".govuk-tag--turquoise", text: "Rejected by provider")
    end
  end

  context "when the claim's status is 'sampling_not_approved'" do
    let(:claim) { build(:claim, status: :sampling_not_approved) }

    it "renders a turquoise tag" do
      expect(page).to have_css(".govuk-tag--turquoise", text: "Rejected by school")
    end
  end

  context "when the claim's status is 'clawback_requested'" do
    let(:claim) { build(:claim, status: :clawback_requested) }

    it "renders a turquoise tag" do
      expect(page).to have_css(".govuk-tag--turquoise", text: "Ready for clawback")
    end
  end

  context "when the claim's status is 'clawback_in_progress'" do
    let(:claim) { build(:claim, status: :clawback_in_progress) }

    it "renders a yellow tag" do
      expect(page).to have_css(".govuk-tag--yellow", text: "Sent to payer for clawback")
    end
  end

  context "when the claim's status is 'clawback_complete'" do
    let(:claim) { build(:claim, status: :clawback_complete) }

    it "renders a blue tag" do
      expect(page).to have_css(".govuk-tag--blue", text: "Clawback complete")
    end
  end

  context "when the claim's status is 'invalid_provider'" do
    let(:claim) { build(:claim, status: :invalid_provider) }

    it "renders a red tag" do
      expect(page).to have_css(".govuk-tag--red", text: "Invalid provider")
    end
  end

  context "when the claim's status is 'clawback_requires_approval'" do
    let(:claim) { build(:claim, status: :clawback_requires_approval) }

    it "renders an orange tag" do
      expect(page).to have_css(".govuk-tag--orange", text: "Clawback requires approval")
    end
  end

  context "when the claim's status is 'clawback_rejected'" do
    let(:claim) { build(:claim, status: :clawback_rejected) }

    it "renders a red tag" do
      expect(page).to have_css(".govuk-tag--red", text: "Clawback rejected")
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
