require "rails_helper"

RSpec.describe Claims::ClaimWindowHelper do
  before { helper.instance_variable_set(:@virtual_path, "claims/support/claim_windows/index") }

  describe "#claim_window_status_tag", freeze: "17 July 2024" do
    subject(:claim_window_status_tag) { helper.claim_window_status_tag(claim_window) }

    context "when given a claim window in the past" do
      let(:claim_window) { Claims::ClaimWindow::Build.call(claim_window_params: { starts_on: Date.parse("14 July 2024"), ends_on: Date.parse("15 July 2024") }) }

      it "returns a grey tag" do
        expect(claim_window_status_tag).to have_css(".govuk-tag--grey", text: "Past")
      end
    end

    context "when given a currently active claim window" do
      let(:claim_window) { Claims::ClaimWindow::Build.call(claim_window_params: { starts_on: Date.parse("16 July 2024"), ends_on: Date.parse("18 July 2024") }) }

      it "returns a green tag" do
        expect(claim_window_status_tag).to have_css(".govuk-tag--green", text: "Current")
      end
    end

    context "when given a claim window scheduled for the future" do
      let(:claim_window) { Claims::ClaimWindow::Build.call(claim_window_params: { starts_on: Date.parse("19 July 2024"), ends_on: Date.parse("20 July 2024") }) }

      it "returns a light blue tag" do
        expect(claim_window_status_tag).to have_css(".govuk-tag--light-blue", text: "Upcoming")
      end
    end
  end
end
