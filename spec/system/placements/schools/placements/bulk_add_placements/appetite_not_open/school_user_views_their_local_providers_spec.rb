require "rails_helper"

RSpec.describe "School user views their local providers",
               service: :placements,
               type: :system do
  scenario do
    given_the_bulk_add_placements_flag_is_enabled
    and_providers_exist
    and_academic_years_exist
    and_i_am_signed_in
    when_i_am_on_the_placements_index_page
    and_i_click_on_bulk_add_placements
    then_i_see_the_appetite_form

    when_i_select_not_open_to_hosting_placements
    and_i_click_on_continue
    then_i_see_the_reasons_for_not_hosting_form

    when_i_select_not_enough_trained_mentors
    and_i_select_number_of_pupils_with_send_needs
    and_i_click_on_continue
    then_i_see_the_help_available_to_you_page
    and_i_see_the_local_providers
  end

  private

  def given_the_bulk_add_placements_flag_is_enabled
    Flipper.add(:bulk_add_placements)
    Flipper.enable(:bulk_add_placements)
  end

  def and_providers_exist
    @provider_1 = create(:provider,
                         name: "London Provider",
                         address1: "London Provider",
                         address2: "The Provider Road",
                         address3: "Somewhere",
                         town: "London",
                         city: "City of London",
                         county: "London",
                         postcode: "LN12 1LN")
    @provider_2 = create(:provider, name: "Brixton Provider",
                                    address1: "Brixton Provider",
                                    address2: "Brixton Road",
                                    town: "London",
                                    postcode: "LN13 3BX")

    allow(Provider).to receive(:near).and_return(
      Provider.where(id: [@provider_1.id, @provider_2.id]),
    )
  end

  def and_academic_years_exist
    current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = current_academic_year.name
    @next_academic_year = current_academic_year.next
    @next_academic_year_name = @next_academic_year.name
  end

  def and_i_am_signed_in
    @school = create(:placements_school)
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_am_on_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(secondary_navigation).to have_current_item("This year (#{@current_academic_year_name}")
    expect(page).to have_link("Add placement")
    expect(page).to have_link("Bulk add placements")
  end
  alias_method :then_i_am_on_the_placements_index_page,
               :when_i_am_on_the_placements_index_page

  def when_i_click_on_bulk_add_placements
    click_on "Bulk add placements"
  end
  alias_method :and_i_click_on_bulk_add_placements,
               :when_i_click_on_bulk_add_placements

  def then_i_see_the_appetite_form
    expect(page).to have_title(
      "Will you host placements this academic year (#{@next_academic_year_name})? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "Will you host placements this academic year (#{@next_academic_year_name})?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Yes - Let providers know what I'm willing to host", type: :radio)
    expect(page).to have_field("Yes - Let providers know I am open to placements", type: :radio)
    expect(page).to have_field("No - Let providers know I am not hosting and do not want to be contacted", type: :radio)
  end

  def when_i_select_not_open_to_hosting_placements
    choose "No - Let providers know I am not hosting and do not want to be contacted"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_the_reasons_for_not_hosting_form
    expect(page).to have_title(
      "What are your reasons for not taking part in ITT this year? - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_element(
      :legend,
      text: "What are your reasons for not taking part in ITT this year?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Not enough trained mentors", type: :checkbox)
    expect(page).to have_field("Number of pupils with SEND needs", type: :checkbox)
    expect(page).to have_field("Working to improve our OFSTED rating", type: :checkbox)
  end

  def when_i_select_not_enough_trained_mentors
    check "Not enough trained mentors"
  end

  def and_i_select_number_of_pupils_with_send_needs
    check "Number of pupils with SEND needs"
  end

  def then_i_see_the_help_available_to_you_page
    expect(page).to have_title(
      "Help available to you - Manage school placements - GOV.UK",
    )
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Help available to you")
  end

  def and_i_see_the_local_providers
    expect(page).to have_element(
      :p,
      text: "London Provider London Provider The Provider Road Somewhere " \
            "London City of London London LN12 1LN",
    )

    expect(page).to have_element(
      :p,
      text: "Brixton Provider Brixton Provider Brixton Road London " \
      "LN13 3BX",
    )
  end
end
