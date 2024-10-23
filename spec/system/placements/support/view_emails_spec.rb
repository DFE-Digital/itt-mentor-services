require "rails_helper"

RSpec.describe "View Emails", service: :placements, type: :system do
  let(:support_user) { create(:placements_support_user) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "User visits the emails page" do
    when_i_visit_the_emails_page
    then_i_can_see_the_list_of_placements_email_templates
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_emails_page
    click_on "Settings"
    click_on "Emails"
  end

  def then_i_can_see_the_list_of_placements_email_templates
    expect(page).to have_content("Support User Mailer")
    expect(page).to have_link("support_user_invitation (opens in new tab)", href: "/rails/mailers/placements/support_user_mailer/support_user_invitation")
    expect(page).to have_link("support_user_removal_notification (opens in new tab)", href: "/rails/mailers/placements/support_user_mailer/support_user_removal_notification")

    expect(page).to have_content("Provider User Mailer")
    expect(page).to have_link("partnership_created_notification (opens in new tab)", href: "/rails/mailers/placements/provider_user_mailer/partnership_created_notification")
    expect(page).to have_link("partnership_destroyed_notification (opens in new tab)", href: "/rails/mailers/placements/provider_user_mailer/partnership_destroyed_notification")
    expect(page).to have_link("placement_provider_assigned_notification (opens in new tab)", href: "/rails/mailers/placements/provider_user_mailer/placement_provider_assigned_notification")
    expect(page).to have_link("placement_provider_removed_notification (opens in new tab)", href: "/rails/mailers/placements/provider_user_mailer/placement_provider_removed_notification")
    expect(page).to have_link("user_membership_created_notification (opens in new tab)", href: "/rails/mailers/placements/provider_user_mailer/user_membership_created_notification")
    expect(page).to have_link("user_membership_destroyed_notification (opens in new tab)", href: "/rails/mailers/placements/provider_user_mailer/user_membership_destroyed_notification")

    expect(page).to have_content("School User Mailer")
    expect(page).to have_link("partnership_created_notification (opens in new tab)", href: "/rails/mailers/placements/school_user_mailer/partnership_created_notification")
    expect(page).to have_link("partnership_destroyed_notification (opens in new tab)", href: "/rails/mailers/placements/school_user_mailer/partnership_destroyed_notification")
    expect(page).to have_link("user_membership_created_notification (opens in new tab)", href: "/rails/mailers/placements/school_user_mailer/user_membership_created_notification")
    expect(page).to have_link("user_membership_destroyed_notification (opens in new tab)", href: "/rails/mailers/placements/school_user_mailer/user_membership_destroyed_notification")
  end
end
