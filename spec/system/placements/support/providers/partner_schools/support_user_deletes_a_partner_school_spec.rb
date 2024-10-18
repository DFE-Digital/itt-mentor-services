require "rails_helper"

RSpec.describe "Placements / Support / Providers / Partner schools / Support user deletes a partner school",
               service: :placements, type: :system do
  include ActiveJob::TestHelper

  let!(:provider) { create(:placements_provider) }
  let!(:school) { create(:school, :placements, name: "School 1") }
  let!(:another_school) { create(:school, name: "Another school") }
  let(:partnership) { create(:placements_partnership, school:, provider:) }
  let(:another_partnership) do
    create(:placements_partnership, provider:, school: another_school)
  end
  let!(:school_user) { create(:placements_user, schools: [school]) }

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  before do
    partnership
    another_partnership
    given_i_am_signed_in_as_a_placements_support_user
  end

  scenario "Support user deletes a partner school" do
    when_i_visit_the_partner_schools_page_for(provider:, school:)
    and_i_click_on("Delete school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Cancel")
    then_i_return_to_partner_school_page(school)
    when_i_click_on("Delete school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Delete school")
    then_the_partner_school_is_deleted(school)
    and_a_partner_provider_remains_called("Another school")
    and_a_notification_email_is_sent_to(school_user)
  end

  context "when the provider has placements associated with the partnership" do
    let(:english) { create(:subject, name: "English") }
    let(:maths) { create(:subject, name: "Mathematics") }
    let(:science) { create(:subject, name: "Science") }

    let(:placements_school) { school.becomes(Placements::School) }
    let(:english_placement) { create(:placement, school: placements_school, provider:, subject: english) }
    let(:maths_placement) { create(:placement, school: placements_school, provider:, subject: maths) }
    let(:science_placement) { create(:placement, school: placements_school, provider:, subject: science) }

    before do
      english_placement
      maths_placement
      science_placement
    end

    scenario "Support user deletes a partner school, and see the placements listed" do
      when_i_visit_the_partner_schools_page_for(provider:, school:)
      and_i_click_on("Delete school")
      then_i_am_asked_to_confirm_partner_school(school)
      and_i_see_a_list_of_associated_placements_with_partner_school_and_provider
      when_i_click_on("Cancel")
      then_i_return_to_partner_school_page(school)
      when_i_click_on("Delete school")
      then_i_am_asked_to_confirm_partner_school(school)
      when_i_click_on("Delete school")
      then_the_partner_school_is_deleted(school)
      and_a_partner_provider_remains_called("Another school")
      and_a_notification_email_is_sent_to(school_user)
    end
  end

  scenario "Support user deletes a partner school, which is not onboarded on the placements service" do
    given_the_school_is_not_onboarded_on_placements_service(school)
    when_i_visit_the_partner_schools_page_for(provider:, school:)
    and_i_click_on("Delete school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Cancel")
    then_i_return_to_partner_school_page(school)
    when_i_click_on("Delete school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Delete school")
    then_the_partner_school_is_deleted(school)
    and_a_partner_provider_remains_called("Another school")
    and_a_notification_email_is_not_sent_to(school_user)
  end

  private

  def when_i_visit_the_partner_schools_page_for(provider:, school:)
    visit placements_provider_partner_school_path(provider, school)

    then_i_see_support_navigation_with_organisation_selected
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".govuk-header__navigation-list") do
      expect(page).to have_link "Organisations"
      expect(page).to have_link "Support users"
    end
  end

  def partner_schools_is_selected_in_secondary_nav
    within(".app-primary-navigation__list") do
      expect(page).to have_link "Organisation details", current: "false"
      expect(page).to have_link "Users", current: "false"
    end
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_am_asked_to_confirm_partner_school(school)
    expect(page).to have_title(
      "Are you sure you want to delete this partner school? - #{school.name} " \
        "- Manage school placements",
    )
    expect(page).to have_content school.name
    expect(page).to have_content "Are you sure you want to delete this school?"
  end

  def then_i_return_to_partner_school_page(school)
    expect(page).to have_current_path placements_provider_partner_school_path(provider, school),
                                      ignore_query: true
  end

  def then_the_partner_school_is_deleted(school)
    partner_schools_is_selected_in_secondary_nav

    expect(provider.partner_schools.find_by(id: school.id)).to be_nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "School deleted"
    end

    expect(page).to have_content school.name, count: 1
  end

  def and_a_partner_provider_remains_called(provider_name)
    expect(page).to have_content(provider_name)
  end

  def partner_school_notification(user)
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(user.email) &&
        delivery.subject == "A teacher training provider has removed your organisation from its list of partner schools"
    end
  end

  def and_a_notification_email_is_sent_to(user)
    email = partner_school_notification(user)

    expect(email).not_to be_nil
  end

  def and_a_notification_email_is_not_sent_to(user)
    email = partner_school_notification(user)

    expect(email).to be_nil
  end

  def given_the_school_is_not_onboarded_on_placements_service(school)
    school.update!(placements_service: false)
  end

  def and_i_see_a_list_of_associated_placements_with_partner_school_and_provider
    expect(page).to have_link("English (opens in new tab)")
    expect(page).to have_link("Mathematics (opens in new tab)")
    expect(page).to have_link("Science (opens in new tab)")
  end
end
