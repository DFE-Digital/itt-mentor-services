require "rails_helper"

RSpec.describe "Placements / Support / Providers / Partner schools / Support user removes a partner school",
               type: :system,
               service: :placements do
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
    given_i_am_signed_in_as_a_support_user
  end

  scenario "Support user removes a partner school" do
    when_i_visit_the_partner_schools_page_for(provider:, school:)
    and_i_click_on("Remove partner school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Cancel")
    then_i_return_to_partner_school_page(school)
    when_i_click_on("Remove partner school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Remove partner school")
    then_the_partner_school_is_removed(school)
    and_a_partner_provider_remains_called("Another school")
    and_a_notification_email_is_sent_to(school_user)
  end

  scenario "Support user removes a partner school, which is not onboarded on the placements service" do
    given_the_school_is_not_onboarded_on_placements_service(school)
    when_i_visit_the_partner_schools_page_for(provider:, school:)
    and_i_click_on("Remove partner school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Cancel")
    then_i_return_to_partner_school_page(school)
    when_i_click_on("Remove partner school")
    then_i_am_asked_to_confirm_partner_school(school)
    when_i_click_on("Remove partner school")
    then_the_partner_school_is_removed(school)
    and_a_partner_provider_remains_called("Another school")
    and_a_notification_email_is_not_sent_to(school_user)
  end

  private

  def given_i_am_signed_in_as_a_support_user
    user = create(:placements_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_partner_schools_page_for(provider:, school:)
    visit placements_support_provider_partner_school_path(provider, school)

    then_i_see_support_navigation_with_organisation_selected
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisations", current: "page"
      expect(page).to have_link "Support users", current: "false"
    end
  end

  def partner_schools_is_selected_in_secondary_nav
    within(".app-secondary-navigation__list") do
      expect(page).to have_link "Details", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Partner schools", current: "page"
    end
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_i_am_asked_to_confirm_partner_school(school)
    expect(page).to have_title(
      "Are you sure you want to remove this partner school? - #{school.name} " \
        "- #{provider.name} - Manage school placements",
    )
    expect(page).to have_content school.name
    expect(page).to have_content "Are you sure you want to remove this partner school?"
  end

  def then_i_return_to_partner_school_page(school)
    expect(page).to have_current_path placements_support_provider_partner_school_path(provider, school),
                                      ignore_query: true
  end

  def then_the_partner_school_is_removed(school)
    partner_schools_is_selected_in_secondary_nav

    expect(provider.partner_schools.find_by(id: school.id)).to eq nil
    within(".govuk-notification-banner__content") do
      expect(page).to have_content "Partner school removed"
    end

    expect(page).not_to have_content school.name
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
end
