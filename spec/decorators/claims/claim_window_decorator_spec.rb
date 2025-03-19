require "rails_helper"

RSpec.describe Claims::ClaimWindowDecorator do
  describe "#name" do
    let(:academic_year) do
      create(
        :academic_year,
        starts_on: Date.parse("1 September 2025"),
        ends_on: Date.parse("31 August 2026"),
        name: "2025 to 2026",
      )
    end
    let(:claim_window) do
      create(
        :claim_window,
        starts_on: Date.parse("1 October 2025"),
        ends_on: Date.parse("31 December 2025"),
        academic_year:,
      )
    end

    it "returns a formatted name based on the start and ends on dates" do
      expect(claim_window.decorate.name).to eq(
        "1 October 2025 to 31 December 2025",
      )
    end
  end
end
