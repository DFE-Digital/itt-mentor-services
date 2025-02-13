require "rails_helper"

RSpec.describe Claims::Support::Claim::ActionsComponent, type: :component do
  before { render_inline(described_class.new(claim:)) }

  context "when claim status is submitted" do
    let(:claim) { create(:claim, :submitted) }

    it "does not render actions" do
      expect(page).not_to have_element(:div, class: "claim-actions")
    end
  end

  context "when claim status is paid" do
    let(:claim) { create(:claim, :paid) }

    it "does not renders actions" do
      expect(page).not_to have_element(:div, class: "claim-actions")
    end
  end

  context "when claim status is payment information requested" do
    let(:claim) { create(:claim, :payment_information_requested, unpaid_reason: "Reason") }

    it "renders actions" do
      expect(page).to have_element(:div, class: "claim-actions")

      expect(page).to have_element(:a, text: "Confirm information sent", class: "govuk-button")
      expect(page).to have_link("Confirm information sent", href: "/support/claims/payments/claims/#{claim.id}/information-sent")

      expect(page).to have_element(:a, text: "Reject claim", class: "govuk-button")
      expect(page).to have_link("Reject claim", href: "/support/claims/payments/claims/#{claim.id}/reject")
    end
  end

  context "when claim status is payment information sent" do
    let(:claim) { create(:claim, :payment_information_sent, unpaid_reason: "Reason") }

    it "renders actions" do
      expect(page).to have_element(:div, class: "claim-actions")

      expect(page).to have_element(:a, text: "Confirm claim paid", class: "govuk-button")
      expect(page).to have_link("Confirm claim paid", href: "/support/claims/payments/claims/#{claim.id}/paid")

      expect(page).to have_element(:a, text: "Reject claim", class: "govuk-button")
      expect(page).to have_link("Reject claim", href: "/support/claims/payments/claims/#{claim.id}/reject")
    end
  end

  context "when claim status is payment not approved" do
    let(:claim) { create(:claim, :payment_not_approved) }

    it "does not renders actions" do
      expect(page).not_to have_element(:div, class: "claim-actions")
    end
  end

  context "when claim status is sampling in progress" do
    let(:claim) { create(:claim, :audit_requested, sampling_reason: "Reason") }

    it "renders actions" do
      expect(page).to have_element(:div, class: "claim-actions")

      expect(page).to have_element(:a, text: "Approve claim", class: "govuk-button")
      expect(page).to have_link("Approve claim", href: "/support/claims/sampling/claims/#{claim.id}/confirm_approval")

      expect(page).to have_element(:a, text: "Confirm provider rejected claim")
      expect(page).to have_link("Confirm provider rejected claim", href: "/support/claims/sampling/claims/#{claim.id}/provider_rejected/new")
    end
  end

  context "when claim status is sampling provider not approved" do
    let(:claim) { create(:claim, :sampling_provider_not_approved) }

    it "renders actions" do
      expect(page).to have_element(:div, class: "claim-actions")

      expect(page).to have_element(:a, text: "Approve claim", class: "govuk-button")
      expect(page).to have_link("Approve claim", href: "/support/claims/sampling/claims/#{claim.id}/confirm_approval")

      expect(page).to have_element(:a, text: "Reject claim", class: "govuk-button")
      expect(page).to have_link("Reject claim", href: "/support/claims/sampling/claims/#{claim.id}/reject/new")
    end
  end

  context "when claim status is sampling not approved" do
    let(:claim) { create(:claim, :sampling_not_approved) }

    it "renders actions" do
      expect(page).to have_element(:div, class: "claim-actions")

      expect(page).to have_element(:a, text: "Request clawback", class: "govuk-button")
      expect(page).to have_link("Request clawback", href: "/support/claims/clawbacks/claims/new/#{claim.id}")
    end
  end

  context "when claim status is clawback requested" do
    let(:claim) { create(:claim, :clawback_requested) }

    it "does not renders actions" do
      expect(page).not_to have_element(:div, class: "claim-actions")
    end
  end

  context "when claim status is clawback in progress" do
    let(:claim) { create(:claim, :clawback_in_progress) }

    it "does not renders actions" do
      expect(page).not_to have_element(:div, class: "claim-actions")
    end
  end

  context "when claim status is clawback complete" do
    let(:claim) { create(:claim, :clawback_complete) }

    it "does not renders actions" do
      expect(page).not_to have_element(:div, class: "claim-actions")
    end
  end
end
