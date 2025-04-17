require "rails_helper"

RSpec.describe Placements::Schools::InterestTagComponent, type: :component do
  subject(:component) do
    described_class.new(school:)
  end

  let(:school) { create(:placements_school, hosting_interests:, placements:) }

  before do
    school
    render_inline(component)
  end

  context "when the school is open to hosting" do
    let(:hosting_interests) { [build(:hosting_interest, appetite: "actively_looking")] }

    context "when the school has available placements" do
      let(:placements) { [build(:placement)] }

      it "renders the correct text" do
        expect(page).to have_content "Has unfilled placements"
      end

      it "renders the correct tag" do
        expect(page).to have_css(".govuk-tag--green")
      end
    end

    context "when the school has available and unavailable placements" do
      let(:placements) { [build(:placement), build(:placement, provider: build(:provider))] }

      it "renders the correct text" do
        expect(page).to have_content "Has unfilled placements"
      end

      it "renders the correct tag" do
        expect(page).to have_css(".govuk-tag--green")
      end
    end

    context "when the school only has unavailable placements" do
      let(:placements) { [build(:placement, provider: build(:provider))] }

      it "renders the correct text" do
        expect(page).to have_content "Already organised placements"
      end

      it "renders the correct tag" do
        expect(page).to have_css(".govuk-tag--blue")
      end
    end

    context "when the school has no placements" do
      let(:placements) { [] }

      it "renders the correct text" do
        expect(page).to have_content "Open to hosting"
      end

      it "renders the correct tag" do
        expect(page).to have_css(".govuk-tag--yellow")
      end
    end
  end

  context "when the school is not open to hosting" do
    let(:hosting_interests) { [build(:hosting_interest, appetite: "not_open")] }
    let(:placements) { [] }

    it "renders the correct text" do
      expect(page).to have_content "Not hosting"
    end

    it "renders the correct tag" do
      expect(page).to have_css(".govuk-tag--red")
    end
  end

  context "when the school has not specified a hosting interest" do
    let(:school) { create(:placements_school) }

    it "renders the correct text" do
      expect(page).to have_content "Not participating"
    end

    it "renders the correct tag" do
      expect(page).to have_css(".govuk-tag--grey")
    end
  end
end
