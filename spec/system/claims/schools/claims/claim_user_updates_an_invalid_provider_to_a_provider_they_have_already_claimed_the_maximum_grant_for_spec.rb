require "rails_helper"

RSpec.describe "Claim user updates an invalid provider to a provider they have already claimed the maximum grant for",
               :js,
               service: :claims,
               type: :system do
  scenario do
    given_an_eligible_school_exists_with_an_invalid_provider_claim
    and_the_school_has_another_claim_for_the_best_practice_network
    and_i_am_signed_in
    then_i_see_the_claims_index_page_with_the_invalid_provider_claim
    and_i_see_the_best_practice_network_claim

    when_i_click_on_the_claim_reference
    then_i_see_the_claim_show_page

    when_i_click_on_change_provider
    then_i_see_the_accredited_provider_page_with_an_empty_input

    when_i_enter_a_provider_named_best_practice_network
    and_i_click_the_dropdown_item_for_best_practice_network
    and_i_click_on_continue
    then_i_see_the_unable_to_assign_provider_page

    when_i_click_on_change_the_accredited_provider
    then_i_see_the_accredited_provider_page_with_an_empty_input
  end

  private

  def given_an_eligible_school_exists_with_an_invalid_provider_claim
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor_james = build(:claims_mentor, first_name: "James", last_name: "Jameson")
    @provider = create(:claims_provider, :best_practice_network, accredited: true) do |provider|
      provider.provider_email_addresses.build(email_address: "best_practice_network@example.com", primary: true)
    end
    @unaccredited_provider = build(:claims_provider, name: "Unaccredited provider")
    @claim_window = build(:claim_window, :current)
    @date_completed = @claim_window.starts_on + 1.day
    @shelbyville_school = build(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligible_claim_windows: [@claim_window],
      mentors: [@mentor_james],
    )
    @claim = build(:claim,
                   :invalid_provider,
                   school: @shelbyville_school,
                   reference: "88888888",
                   provider: @unaccredited_provider,
                   claim_window: @claim_window,
                   created_by: @user_anne)
    @mentor_training = create(:mentor_training,
                              claim: @claim,
                              mentor: @mentor_james,
                              hours_completed: 8,
                              provider: @unaccredited_provider,
                              date_completed: @date_completed)
  end

  def and_the_school_has_another_claim_for_the_best_practice_network
    @bpn_claim = build(:claim,
                       :submitted,
                       school: @shelbyville_school,
                       reference: "99999999",
                       provider: @provider,
                       claim_window: @claim_window,
                       created_by: @user_anne)
    @bpn_mentor_training = create(:mentor_training,
                                  claim: @bpn_claim,
                                  mentor: @mentor_james,
                                  hours_completed: 20,
                                  provider: @provider,
                                  date_completed: @date_completed)
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def then_i_see_the_claims_index_page_with_the_invalid_provider_claim
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(page).to have_link("Add claim", href: "/schools/#{@shelbyville_school.id}/claims/new")
    expect(page).to have_table_row({
      "Reference" => "88888888",
      "Accredited provider" => "Unaccredited provider",
      "Mentors" => "James Jameson",
      "Amount" => "£#{@shelbyville_school.region.funding_available_per_hour * 8}",
      "Date submitted" => "-",
      "Status" => "Invalid provider",
    })
  end

  def and_i_see_the_best_practice_network_claim
    expect(page).to have_table_row({
      "Reference" => "99999999",
      "Accredited provider" => "Best Practice Network",
      "Mentors" => "James Jameson",
      "Amount" => "£#{ActiveSupport::NumberHelper.number_to_delimited(@shelbyville_school.region.funding_available_per_hour * 20)}",
      "Date submitted" => @bpn_claim.submitted_at.strftime("%-d %B %Y").to_s,
      "Status" => "Submitted",
    })
  end

  def when_i_click_on_the_claim_reference
    click_on "88888888"
  end

  def then_i_see_the_claim_show_page
    expect(page).to have_title("Claim - 88888888 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claim - 88888888")
    expect(page).to have_tag("Invalid provider", "red")
    expect(page).to have_warning_text("The accredited provider for this claim is invalid. Use the change link below to record an accredited provider so this claim can be paid.")
    expect(page).to have_h2("Details")
    expect(page).to have_summary_list_row("School", "Shelbyville Elementary")
    expect(page).to have_summary_list_row("Academic year", @claim_window.academic_year.name.to_s)
    expect(page).to have_summary_list_row("Accredited provider", "Unaccredited provider")
    expect(page).to have_summary_list_row("Mentors", "James Jameson")

    expect(page).to have_h2("Hours of training")
    expect(page).to have_summary_list_row("James Jameson", "8 hours")

    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Total hours", "8 hours")
    expect(page).to have_summary_list_row("Hourly rate", "£#{@shelbyville_school.region.funding_available_per_hour}")
    expect(page).to have_summary_list_row("Claim amount", "£#{@shelbyville_school.region.funding_available_per_hour * 8}")
  end

  def when_i_click_on_change_provider
    click_on "Change Accredited provider"
  end

  def then_i_see_the_accredited_provider_page_with_an_empty_input
    expect(page).to have_title("Enter the accredited provider for this claim - Claim details - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_hint("You must make a separate claim for each accredited provider you work with.")
    expect(page).to have_element(:input, class: "autocomplete__input autocomplete__input--default", id: "claims-add-claim-wizard-provider-step-id-field", value: nil)
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel")
  end

  def when_i_enter_a_provider_named_best_practice_network
    fill_in "Enter the accredited provider", with: "Best Practice Network"
  end

  def and_i_click_the_dropdown_item_for_best_practice_network
    page.find(".autocomplete__option", text: "Best Practice Network").click
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def when_i_navigate_back_to_the_claims_index_page
    within ".app-primary-navigation" do
      click_on "Claims"
    end
  end

  def then_i_see_the_unable_to_assign_provider_page
    expect(page).to have_title("Unable to assign provider - Claim details - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Unable to assign provider")
    expect(page).to have_span_caption("Claim details")

    expect(page).to have_paragraph(
      "You can not assign this claim to Best Practice Network.",
    )
    expect(page).to have_paragraph(
      "There are mentors included in this claim who have already had 20 hours of training," \
      " or will exceed 20 hours of training, claimed for with Best Practice Network.",
    )
    expect(page).to have_paragraph(
      "Please review the claims that have already been submitted for your mentors.",
    )
    expect(page).to have_link("claims", href: claims_school_claims_path(@shelbyville_school))
    expect(page).to have_paragraph(
      "You may need to delete this claim and submit another claim for Best Practice Network, or another provider.",
    )
    expect(page).to have_link(
      "delete this claim",
      href: remove_claims_school_claim_path(@shelbyville_school, @claim),
      class: "app-link app-link--destructive",
    )
    expect(page).to have_link("Change the accredited provider")
  end

  def when_i_click_on_change_the_accredited_provider
    click_on "Change the accredited provider"
  end
end
