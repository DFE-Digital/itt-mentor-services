require "rails_helper"

RSpec.describe "Service updates page", type: :system do
  context "when user is on the Claims site", service: :claims do
    before do
      allow(YAML).to receive(:load_file).with(Rails.root.join("db/claims_service_updates.yml"), symbolize_names: true).and_return([
        {
          date: "2023-01-01",
          title: "Service update",
          content: "Service update 1",
        },
      ])
    end

    scenario "User visits the Service updates page" do
      and_i_am_on_the_service_updates_page
      i_can_see_the_claims_service_title
      i_can_see_the_claims_service_updates
    end
  end

  context "when user is on the Placements site", service: :placements do
    before do
      allow(YAML).to receive(:load_file).with(Rails.root.join("db/placements_service_updates.yml"), symbolize_names: true).and_return([
        {
          date: "2023-01-01",
          title: "Service update",
          content: "Service update 1",
        },
      ])
    end

    scenario "User visits the Service updates page" do
      and_i_am_on_the_service_updates_page
      i_can_see_the_placements_service_title
      i_can_see_the_placements_service_updates
    end
  end

  private

  def and_i_am_on_the_service_updates_page
    visit "/service_updates"
  end

  def i_can_see_the_claims_service_title
    within(".govuk-heading-xl") do
      expect(page).to have_content("Claims news and updates")
    end
  end

  def i_can_see_the_claims_service_updates
    within("#service-update") do
      expect(page).to have_content("Service update\n1 January 2023\nService update 1")
    end
  end

  def i_can_see_the_placements_service_title
    within(".govuk-heading-xl") do
      expect(page).to have_content("Placements news and updates")
    end
  end

  def i_can_see_the_placements_service_updates
    within("#service-update") do
      expect(page).to have_content("Service update\n1 January 2023\nService update 1")
    end
  end
end
