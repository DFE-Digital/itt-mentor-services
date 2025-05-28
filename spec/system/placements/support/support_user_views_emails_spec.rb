require "rails_helper"

RSpec.describe "Support user views emails", service: :placements, type: :system do
  scenario do
    given_i_am_signed_in
    when_i_navigate_to_settings
    and_i_click_on_emails
    then_i_can_see_the_list_of_placements_email_templates
  end

  private

  def given_i_am_signed_in
    sign_in_placements_support_user
  end

  def when_i_navigate_to_settings
    within(header_navigation) do
      click_on "Settings"
    end
  end

  def and_i_click_on_emails
    click_on "Emails"
  end

  def then_i_can_see_the_list_of_placements_email_templates
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
    expect(page).to have_link("placement_provider_removed_notification (opens in new tab)", href: "/rails/mailers/placements/school_user_mailer/placement_provider_removed_notification")
    expect(page).to have_link("user_membership_created_notification (opens in new tab)", href: "/rails/mailers/placements/school_user_mailer/user_membership_created_notification")
    expect(page).to have_link("user_membership_destroyed_notification (opens in new tab)", href: "/rails/mailers/placements/school_user_mailer/user_membership_destroyed_notification")

    expect(page).to have_content("Support User Mailer")
    expect(page).to have_link("support_user_invitation (opens in new tab)", href: "/rails/mailers/placements/support_user_mailer/support_user_invitation")
    expect(page).to have_link("support_user_removal_notification (opens in new tab)", href: "/rails/mailers/placements/support_user_mailer/support_user_removal_notification")
  end
end
