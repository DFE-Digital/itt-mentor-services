require "rails_helper"

RSpec.describe "Support user views a schools partner providers",
               service: :placements,
               type: :system do
  scenario do
    given_a_school_exists_with_partner_providers
    and_the_school_partner_providers_flag_is_enabled
    and_i_am_signed_in

    when_i_am_on_the_organisations_index_page
    and_i_select_springfield_elementary
    and_i_navigate_to_providers
    then_i_see_the_providers_you_work_with_page
    and_i_see_the_niot_provider
    and_i_see_the_best_practice_network_provider
    and_i_do_not_see_the_random_provider
  end

  private

  def given_a_school_exists_with_partner_providers
    @niot_provider = build(:placements_provider, :niot, ukprn: 111_111)
    @bpn_provider = build(:provider, :best_practice_network, ukprn: 222_222)
    @random_provider = create(:provider, name: "Random provider")

    @springfield_elementary_school = create(
      :placements_school,
      name: "Springfield Elementary",
      address1: "Westgate Street",
      address2: "Hackney",
      postcode: "E8 3RL",
      group: "Local authority maintained schools",
      phase: "Primary",
      gender: "Mixed",
      minimum_age: 3,
      maximum_age: 11,
      religious_character: "Does not apply",
      admissions_policy: "Not applicable",
      urban_or_rural: "(England/Wales) Urban major conurbation",
      percentage_free_school_meals: 15,
      rating: "Outstanding",
      partner_providers: [@niot_provider, @bpn_provider],
    )
  end

  def and_the_school_partner_providers_flag_is_enabled
    Flipper.add(:school_partner_providers)
    Flipper.enable(:school_partner_providers)
  end

  def and_i_am_signed_in
    sign_in_placements_support_user
  end

  def when_i_am_on_the_organisations_index_page
    expect(page).to have_title("Organisations (2) - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations (2)")
  end

  def and_i_select_springfield_elementary
    click_on "Springfield Elementary"
  end

  def and_i_navigate_to_providers
    within primary_navigation do
      click_on "Providers"
    end
  end

  def then_i_see_the_providers_you_work_with_page
    expect(page).to have_title("Providers you work with - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Providers")
    expect(page).to have_h1("Providers you work with", class: "govuk-heading-l")
    expect(page).to have_element(
      :p,
      text: "Add providers to be able to assign them to your placements.",
      class: "govuk-body",
    )
    expect(page).to have_link("Add provider", class: "govuk-button")
  end

  def and_i_see_the_niot_provider
    expect(page).to have_table_row({
      "Name" => "NIoT: National Institute of Teaching, founded by the School-Led Development Trust",
      "UK provider reference number (UKPRN)" => "111111",
    })
  end

  def and_i_see_the_best_practice_network_provider
    expect(page).to have_table_row({
      "Name" => "Best Practice Network",
      "UK provider reference number (UKPRN)" => "222222",
    })
  end

  def and_i_do_not_see_the_random_provider
    expect(page).not_to have_table_row({
      "Name" => "Random provider",
    })
  end
end
