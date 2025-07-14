require "rails_helper"

RSpec.describe "View Emails", service: :claims, type: :system do
  let(:support_user) { create(:claims_support_user) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "User visits the emails page" do
    when_i_visit_the_emails_page
    then_i_can_see_the_list_of_claims_email_templates
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_emails_page
    click_on "Settings"
    click_on "View email templates"
  end

  def then_i_can_see_the_list_of_claims_email_templates
    expect(page).to have_content("Support User Mailer")
    expect(page).to have_link("support_user_invitation (opens in new tab)", href: "/rails/mailers/claims/support_user_mailer/support_user_invitation")
    expect(page).to have_link("support_user_removal_notification (opens in new tab)", href: "/rails/mailers/claims/support_user_mailer/support_user_removal_notification")

    expect(page).to have_content("User Mailer")
    expect(page).to have_link("claim_created_support_notification (opens in new tab)", href: "/rails/mailers/claims/user_mailer/claim_created_support_notification")
    expect(page).to have_link("claim_submitted_notification (opens in new tab)", href: "/rails/mailers/claims/user_mailer/claim_submitted_notification")
    expect(page).to have_link("user_membership_created_notification (opens in new tab)", href: "/rails/mailers/claims/user_mailer/user_membership_created_notification")
    expect(page).to have_link("user_membership_destroyed_notification (opens in new tab)", href: "/rails/mailers/claims/user_mailer/user_membership_destroyed_notification")
  end
end
