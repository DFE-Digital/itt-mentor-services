require "rails_helper"

RSpec.describe "Support user views who amended a provider rejected claim", service: :claims, type: :system do
  scenario do
    given_a_claim_is_being_audited
    and_i_am_signed_in_as_a_provider_user

    when_i_amend_the_claim
    and_i_sign_out
    and_i_am_signed_in_as_a_support_user
    and_i_view_the_claim
    then_i_see_who_amended_the_claim
  end

  private

  def given_a_claim_is_being_audited
    @provider = create(:claims_provider, name: "North Star SCITT")
    @provider_user = create(:claims_provider_user, :patricia)
    @provider.users << @provider_user
    @mentor = create(:claims_mentor, first_name: "James", last_name: "Chess")
    @claim = create(:claim, :submitted, status: :sampling_in_progress, provider: @provider, reference: "11111111")
    create(:mentor_training, claim: @claim, mentor: @mentor, provider: @provider, hours_completed: 20)
  end

  def and_i_am_signed_in_as_a_provider_user
    sign_in_as(@provider_user)
  end

  def when_i_amend_the_claim
    visit claims_provider_claim_path(@provider, @claim)
    click_on "Amend claim"
    check "James Chess"
    click_on "Continue"
    choose "Enter the hours of training the mentor completed"
    fill_in "Number of hours", with: 10
    fill_in "Why are you amending this?", with: "Incorrect number of hours"
    click_on "Continue"
    click_on "Confirm"

    expect(page).to have_success_banner("Claim amended successfully")
  end

  def and_i_sign_out
    Capybara.reset_session!
  end

  def and_i_am_signed_in_as_a_support_user
    sign_in_claims_support_user
  end

  def and_i_view_the_claim
    visit claims_support_claim_path(@claim)
  end

  def then_i_see_who_amended_the_claim
    within(".claim-responses", text: "Provider response") do
      expect(page).to have_element(:p, text: "Amended by Patricia Adebayo on #{I18n.l(Date.current, format: :long)}.", class: "govuk-body")
    end
  end
end
