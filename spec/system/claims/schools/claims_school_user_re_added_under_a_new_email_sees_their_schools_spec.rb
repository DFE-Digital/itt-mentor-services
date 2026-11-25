require "rails_helper"

RSpec.describe "Claims school user re-added under a new email sees their schools", service: :claims, type: :system do
  scenario do
    given_two_schools_exist
    and_anne_has_signed_in_before_with_her_old_email
    and_anne_has_been_re_added_to_two_schools_under_her_new_email
    and_her_dfe_sign_in_account_uses_her_new_email

    when_i_visit_the_sign_in_path
    and_i_click_sign_in
    then_i_see_both_schools_on_the_organisations_page

    when_i_visit_my_account_page
    then_i_see_my_new_email
  end

  private

  def given_two_schools_exist
    @shelbyville_school = create(:claims_school, name: "Shelbyville Elementary")
    @springfield_school = create(:claims_school, name: "Springfield Elementary")
  end

  def and_anne_has_signed_in_before_with_her_old_email
    @anne = create(
      :claims_user,
      first_name: "Anne",
      last_name: "Wilson",
      email: "anne.wilson@old-school.example.com",
      dfe_sign_in_uid: "anne-dfe-uid",
      last_signed_in_at: 1.year.ago,
    )
  end

  def and_anne_has_been_re_added_to_two_schools_under_her_new_email
    unused_anne = create(
      :claims_user,
      first_name: "Anne",
      last_name: "Wilson",
      email: "anne.wilson@new-school.example.com",
      dfe_sign_in_uid: nil,
      last_signed_in_at: nil,
    )
    create(:user_membership, user: unused_anne, organisation: @shelbyville_school)
    create(:user_membership, user: unused_anne, organisation: @springfield_school)
  end

  def and_her_dfe_sign_in_account_uses_her_new_email
    user_exists_in_dfe_sign_in(
      user: build(
        :claims_user,
        first_name: "Anne",
        last_name: "Wilson",
        email: "anne.wilson@new-school.example.com",
        dfe_sign_in_uid: "anne-dfe-uid",
      ),
    )
  end

  def when_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def and_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def then_i_see_both_schools_on_the_organisations_page
    expect(page).to have_current_path(claims_schools_path)
    expect(page).to have_h1("Organisations")
    expect(page).to have_link("Shelbyville Elementary", href: claims_school_claims_path(@shelbyville_school))
    expect(page).to have_link("Springfield Elementary", href: claims_school_claims_path(@springfield_school))
  end

  def when_i_visit_my_account_page
    visit account_path
  end

  def then_i_see_my_new_email
    expect(page).to have_content("anne.wilson@new-school.example.com")
    expect(page).to have_no_content("anne.wilson@old-school.example.com")
  end
end
