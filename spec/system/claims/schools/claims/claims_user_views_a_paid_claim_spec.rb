require "rails_helper"

RSpec.describe "Claims user views a paid claim", service: :claims, type: :system do
  scenario do
    given_an_eligible_school_exists_with_a_paid_claim
    and_i_am_signed_in

    when_i_click_on_the_claim_reference
    then_i_see_the_payment_details

    when_the_claim_was_paid_to_the_academy
    and_i_click_on_the_claim_reference
    then_i_see_the_claim_was_paid_to_the_academy
  end

  private

  def given_an_eligible_school_exists_with_a_paid_claim
    @user_anne = build(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @mentor = build(:claims_mentor, first_name: "James", last_name: "Jameson")
    @provider = build(:claims_provider, :best_practice_network)
    @claim_window = Claims::ClaimWindow.current || create(:claim_window, :current)
    @eligibility = build(:eligibility, claim_window: @claim_window)
    @shelbyville_school = build(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
      eligibilities: [@eligibility],
      mentors: [@mentor],
    )
    @paid_claim = create(
      :claim,
      :paid,
      school: @shelbyville_school,
      reference: "88888888",
      provider: @provider,
      claim_window: @claim_window,
      paid_to_la: true,
      date_paid: Date.new(2026, 9, 21),
      mentor_trainings: [
        build(:mentor_training, mentor: @mentor, hours_completed: 8, provider: @provider),
      ],
    )
  end

  def and_i_am_signed_in
    sign_in_as(@user_anne)
  end

  def when_i_click_on_the_claim_reference
    click_on "88888888"
  end
  alias_method :and_i_click_on_the_claim_reference, :when_i_click_on_the_claim_reference

  def then_i_see_the_payment_details
    expect(page).to have_h1("Claim - 88888888")
    expect(page).to have_h2("Payment details")
    expect(page).to have_summary_list_row("Date paid", "21 September 2026")
    expect(page).to have_summary_list_row("Paid to", "Local authority")
  end

  def when_the_claim_was_paid_to_the_academy
    @paid_claim.update!(paid_to_la: false)
    visit claims_school_claims_path(@shelbyville_school)
  end

  def then_i_see_the_claim_was_paid_to_the_academy
    expect(page).to have_summary_list_row("Paid to", "Academy")
  end
end
