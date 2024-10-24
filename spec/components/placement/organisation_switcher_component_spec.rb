require "rails_helper"

RSpec.describe Placement::OrganisationSwitcherComponent, type: :component do
  subject(:component) do
    described_class.new(user:, organisation:)
  end

  let(:organisation) { create(:placements_school) }

  context "when the user is a support user" do
    let(:user) { create(:placements_support_user) }

    it "renders the organisation switcher" do
      render_inline(component)

      within(".content-header") do
        expect(page).to have_content(organisation.name)
        expect(page).to have_link(
          text: "Change organisation",
          href: public_send("placements_support_organisations_path"),
        )
      end
    end
  end

  context "when the user is a non-support user" do
    context "when assigned to multiple organisations" do
      let(:another_school) { create(:placements_school) }
      let(:user) { create(:placements_user, schools: [organisation, another_school]) }

      it "renders the organisation switcher" do
        render_inline(component)

        within(".content-header") do
          expect(page).to have_content(organisation.name)
          expect(page).to have_link(
            text: "Change organisation",
            href: public_send("placements_organisations_path"),
          )
        end
      end
    end

    context "when assigned to only one organisation" do
      let(:user) { create(:placements_user, schools: [organisation]) }

      it "does not render the organisation switcher" do
        render_inline(component)

        within(".content-header") do
          expect(page).not_to have_content(organisation.name)
          expect(page).not_to have_link(
            text: "Change organisation",
            href: public_send("placements_organisations_path"),
          )
        end
      end
    end
  end
end
