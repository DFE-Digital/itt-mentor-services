require "rails_helper"

RSpec.describe "Support user filters clawback claims by provider", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_clawbacks_index_page
    then_i_see_the_clawbacks_index_page
    and_i_see_the_clawback_claim_for_provider_niot
    and_i_see_the_clawback_claim_for_provider_bpn

    when_i_select_niot_from_the_provider_filter
    and_i_click_on_apply_filters
    then_i_see_only_filtered_claims_on_the_clawbacks_index_page
    and_i_see_the_clawback_claim_for_provider_niot
    and_i_do_not_see_the_clawback_claim_for_provider_bpn
    and_i_see_provider_niot_selected_from_the_provider_filter
    and_i_do_not_see_provider_bpn_selected_from_the_provider_filter

    when_i_select_bpn_from_the_provider_filter
    and_i_click_on_apply_filters
    then_i_see_all_claims_on_the_clawbacks_index_page
    and_i_see_the_clawback_claim_for_provider_niot
    and_i_see_the_clawback_claim_for_provider_bpn
    and_i_see_provider_niot_selected_from_the_provider_filter
    and_i_see_provider_bpn_selected_from_the_provider_filter

    when_i_unselect_niot_from_the_provider_filter
    and_i_click_on_apply_filters
    then_i_see_only_filtered_claims_on_the_clawbacks_index_page
    and_i_see_the_clawback_claim_for_provider_bpn
    and_i_do_not_see_the_clawback_claim_for_provider_niot
    and_i_see_provider_bpn_selected_from_the_provider_filter
    and_i_do_not_see_provider_niot_selected_from_the_provider_filter

    when_i_click_on_the_bpn_provider_filter_tag
    then_i_see_all_claims_on_the_clawbacks_index_page
    and_i_see_the_clawback_claim_for_provider_niot
    and_i_see_the_clawback_claim_for_provider_bpn
    and_i_do_not_see_provider_niot_selected_from_the_provider_filter
    and_i_do_not_see_provider_bpn_selected_from_the_provider_filter

    when_i_select_bpn_from_the_provider_filter
    and_i_select_niot_from_the_provider_filter
    and_i_click_on_apply_filters
    then_i_see_all_claims_on_the_clawbacks_index_page
    and_i_see_the_clawback_claim_for_provider_bpn
    and_i_see_the_clawback_claim_for_provider_niot
    and_i_see_provider_bpn_selected_from_the_provider_filter
    and_i_see_provider_niot_selected_from_the_provider_filter

    when_i_click_clear_filters
    then_i_see_all_claims_on_the_clawbacks_index_page
    and_i_see_the_clawback_claim_for_provider_bpn
    and_i_see_the_clawback_claim_for_provider_niot
    and_i_do_not_see_provider_bpn_selected_from_the_provider_filter
    and_i_do_not_see_provider_niot_selected_from_the_provider_filter
  end

  private

  def given_claims_exist
    @provider_niot = create(:claims_provider, :niot)
    @niot_claim = create(:claim,
                         :submitted,
                         status: :clawback_in_progress,
                         provider: @provider_niot)

    @provider_bpn = create(:claims_provider, :best_practice_network)
    @bpn_claim = create(:claim,
                        :submitted,
                        status: :clawback_in_progress,
                        provider: @provider_bpn)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_clawbacks_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Clawbacks"
    end
  end

  def then_i_see_the_clawbacks_index_page
    i_see_the_sampling_index_page
    expect(page).to have_h2("Clawbacks (2)")
  end
  alias_method :then_i_see_all_claims_on_the_clawbacks_index_page,
               :then_i_see_the_clawbacks_index_page

  def then_i_see_only_filtered_claims_on_the_clawbacks_index_page
    i_see_the_sampling_index_page
    expect(page).to have_h2("Clawbacks (1)")
  end

  def i_see_the_sampling_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Clawbacks")
    expect(page).to have_current_path(claims_support_claims_clawbacks_path, ignore_query: true)
  end

  def and_i_see_the_clawback_claim_for_provider_niot
    expect(page).to have_claim_card({
      "title" => "#{@niot_claim.reference} - #{@niot_claim.school.name}",
      "url" => "/support/claims/clawbacks/claims/#{@niot_claim.id}",
      "status" => "Clawback in progress",
      "academic_year" => @niot_claim.academic_year.name,
      "provider_name" => @niot_claim.provider.name,
      "submitted_at" => I18n.l(@niot_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_the_clawback_claim_for_provider_bpn
    expect(page).to have_claim_card({
      "title" => "#{@bpn_claim.reference} - #{@bpn_claim.school.name}",
      "url" => "/support/claims/clawbacks/claims/#{@bpn_claim.id}",
      "status" => "Clawback in progress",
      "academic_year" => @bpn_claim.academic_year.name,
      "provider_name" => @bpn_claim.provider.name,
      "submitted_at" => I18n.l(@bpn_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def when_i_select_niot_from_the_provider_filter
    check @provider_niot.name
  end
  alias_method :and_i_select_niot_from_the_provider_filter,
               :when_i_select_niot_from_the_provider_filter

  def when_i_select_bpn_from_the_provider_filter
    check @provider_bpn.name
  end
  alias_method :and_i_select_bpn_from_the_provider_filter,
               :when_i_select_bpn_from_the_provider_filter

  def when_i_unselect_niot_from_the_provider_filter
    uncheck @provider_niot.name
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def and_i_do_not_see_the_clawback_claim_for_provider_bpn
    expect(page).not_to have_claim_card({
      "title" => "#{@bpn_claim.reference} - #{@bpn_claim.school.name}",
    })
  end

  def and_i_do_not_see_the_clawback_claim_for_provider_niot
    expect(page).not_to have_claim_card({
      "title" => "#{@niot_claim.reference} - #{@niot_claim.school.name}",
    })
  end

  def and_i_see_provider_niot_selected_from_the_provider_filter
    expect(page).to have_element(:legend, text: "Accredited provider", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field(@provider_niot.name)
    expect(page).to have_filter_tag(@provider_niot.name)
  end

  def and_i_see_provider_bpn_selected_from_the_provider_filter
    expect(page).to have_element(:legend, text: "Accredited provider", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field(@provider_bpn.name)
    expect(page).to have_filter_tag(@provider_bpn.name)
  end

  def and_i_do_not_see_provider_bpn_selected_from_the_provider_filter
    expect(page).not_to have_checked_field(@provider_bpn.name)
    expect(page).not_to have_filter_tag(@provider_bpn.name)
  end

  def and_i_do_not_see_provider_niot_selected_from_the_provider_filter
    expect(page).not_to have_checked_field(@provider_niot.name)
    expect(page).not_to have_filter_tag(@provider_niot.name)
  end

  def when_i_click_on_the_bpn_provider_filter_tag
    within ".app-filter-tags" do
      click_on @provider_bpn.name
    end
  end

  def when_i_click_clear_filters
    click_on "Clear filters"
  end
end
