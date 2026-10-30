require "rails_helper"

RSpec.describe "Support user views a forecast for a claim window", service: :claims, type: :system do
  scenario do
    given_claims_exist_in_two_claim_windows
    and_clawbacks_exist_for_the_historic_claim_window
    and_i_am_signed_in
    when_i_navigate_to_the_settings_index_page
    then_i_see_the_forecast_link

    when_i_click_on_the_forecast_link
    then_i_see_the_claim_window_selection_page

    when_i_select_the_historic_claim_window
    and_i_click_on_view_forecast
    then_i_see_the_forecast_for_the_historic_claim_window
    and_i_see_the_total_claims_for_the_historic_claim_window
    and_i_see_pending_and_completed_clawbacks
    and_the_reports_use_four_aggregate_queries

    when_a_pending_clawback_is_completed
    and_i_reload_the_forecast
    then_the_recovery_moves_from_pending_to_completed

    when_i_select_the_current_claim_window
    and_i_click_on_view_forecast
    then_i_see_zero_clawback_totals
  end

  private

  def given_claims_exist_in_two_claim_windows
    @current_claim_window = create(:claim_window, :current)
    @historic_claim_window = create(:claim_window, :historic)

    @community_school = create(:claims_school, group: "Local authority maintained schools", type_of_establishment: "Community school")
    @academy = create(:claims_school, group: "Academies", type_of_establishment: "Academy converter")

    @community_claim = create(:claim, :submitted, school: @community_school, claim_window: @historic_claim_window)
    @academy_claim = create(:claim, :submitted, school: @academy, claim_window: @historic_claim_window)
    @paid_claim = create(:claim, :submitted, status: :paid, school: @academy, claim_window: @historic_claim_window)
    @current_claim = create(:claim, :submitted, school: @academy, claim_window: @current_claim_window)
    create(:claim, :draft, school: @academy, claim_window: @historic_claim_window)

    [@community_claim, @academy_claim, @paid_claim, @current_claim].each do |claim|
      create(:mentor_training, claim:, hours_completed: 10)
    end
  end

  def and_clawbacks_exist_for_the_historic_claim_window
    @approval_claim = create_clawback(:clawback_requires_approval, @academy, 2)
    @requested_claim = create_clawback(:clawback_requested, @community_school, 3)
    @in_progress_claim = create_clawback(:clawback_in_progress, @academy, 4)
    @completed_claim = create_clawback(:clawback_complete, @community_school, 5)
    @rejected_claim = create_clawback(:clawback_rejected, @academy, 6)
    @pending_clawbacks = [@approval_claim, @requested_claim, @in_progress_claim]
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_settings_index_page
    within(primary_navigation) do
      click_on "Settings"
    end
  end

  def then_i_see_the_forecast_link
    expect(page).to have_link("View claim forecast", href: "/support/forecast")
  end

  def when_i_click_on_the_forecast_link
    click_on "View claim forecast"
  end

  def then_i_see_the_claim_window_selection_page
    expect(page).to have_title("Claim forecast - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claim forecast", class: "govuk-heading-l")
    expect(page).to have_field("#{I18n.l(@current_claim_window.starts_on, format: :long)} to #{I18n.l(@current_claim_window.ends_on, format: :long)}")
    expect(page).to have_field("#{I18n.l(@historic_claim_window.starts_on, format: :long)} to #{I18n.l(@historic_claim_window.ends_on, format: :long)}")
    expect(page).not_to have_link("Clawbacks", href: "#clawbacks")
  end

  def when_i_select_the_historic_claim_window
    choose "#{I18n.l(@historic_claim_window.starts_on, format: :long)} to #{I18n.l(@historic_claim_window.ends_on, format: :long)}"
  end

  def and_i_click_on_view_forecast
    @report_queries = []
    record_query = ->(event) { @report_queries << event.payload[:sql] if event.payload[:sql].match?(/\ASELECT/i) && event.payload[:name] != "SCHEMA" }
    ActiveSupport::Notifications.subscribed(record_query, "sql.active_record") do
      click_on "View forecast"
    end
  end

  def then_i_see_the_forecast_for_the_historic_claim_window
    expect(page).to have_checked_field("#{I18n.l(@historic_claim_window.starts_on, format: :long)} to #{I18n.l(@historic_claim_window.ends_on, format: :long)}")
    expect(page).to have_unchecked_field("#{I18n.l(@current_claim_window.starts_on, format: :long)} to #{I18n.l(@current_claim_window.ends_on, format: :long)}")
    expect(page).to have_link("Forecast", href: "#forecast")
    expect(page).to have_link("Total claims", href: "#total-claims")

    within("#forecast") do
      expect(page).to have_h2("Academies")
      expect(page).to have_table_row({ "Type of establishment" => "Academy converter", "Amount" => @academy_claim.amount.format })
      expect(page).to have_h2("Local authority maintained schools")
      expect(page).to have_table_row({ "Type of establishment" => "Community school", "Amount" => @community_claim.amount.format })
      expect(page).to have_table_row({ "All groups" => "Total", "Amount" => (@academy_claim.amount + @community_claim.amount).format })
    end
  end

  def and_i_see_the_total_claims_for_the_historic_claim_window
    academy_total = [@academy_claim, @paid_claim, @approval_claim, @in_progress_claim, @rejected_claim].sum(Money.new(0, "GBP"), &:amount)
    community_total = [@community_claim, @requested_claim, @completed_claim].sum(Money.new(0, "GBP"), &:amount)

    within("#total-claims") do
      expect(page).to have_h2("Academies")
      expect(page).to have_table_row({ "Type of establishment" => "Academy converter", "Amount" => academy_total.format })
      expect(page).to have_h2("Local authority maintained schools")
      expect(page).to have_table_row({ "Type of establishment" => "Community school", "Amount" => community_total.format })
      expect(page).to have_table_row({ "All groups" => "Total", "Amount" => (academy_total + community_total).format })
    end
  end

  def and_i_see_pending_and_completed_clawbacks
    expect(page).to have_link("Clawbacks", href: "#clawbacks")
    within("#pending-clawbacks") do
      expect(page).to have_h2("Pending clawbacks")
      expect(page).to have_paragraph("Includes clawbacks awaiting approval, requested and in progress. Amounts awaiting approval are provisional.")
      expect(page).to have_h3("Academies")
      expect(page).to have_table_row("Type of establishment" => "Academy converter", "Amount" => (@approval_claim.total_clawback_amount + @in_progress_claim.total_clawback_amount).format)
      expect(page).to have_h3("Local authority maintained schools")
      expect(page).to have_table_row("Type of establishment" => "Community school", "Amount" => @requested_claim.total_clawback_amount.format)
      expect(page).to have_table_row("All groups" => "Total", "Amount" => @pending_clawbacks.sum(Money.new(0, "GBP"), &:total_clawback_amount).format)
    end
    within("#completed-clawbacks") do
      expect(page).to have_h2("Completed clawbacks")
      expect(page).to have_h3("Local authority maintained schools")
      expect(page).to have_table_row("Type of establishment" => "Community school", "Amount" => @completed_claim.total_clawback_amount.format)
      expect(page).to have_table_row("All groups" => "Total", "Amount" => @completed_claim.total_clawback_amount.format)
    end
  end

  def and_the_reports_use_four_aggregate_queries
    expect(@report_queries.grep(/SUM\(.*regions\.claims_funding_available_per_hour_pence/i).size).to eq(4)
    expect(@report_queries.grep(/SELECT "(?:claims|mentor_trainings)"\.\*/i)).to be_empty
  end

  def when_a_pending_clawback_is_completed
    @in_progress_claim.update!(status: :clawback_complete)
  end

  def and_i_reload_the_forecast
    visit current_url
  end

  def then_the_recovery_moves_from_pending_to_completed
    within("#pending-clawbacks") do
      expect(page).to have_table_row("All groups" => "Total", "Amount" => (@approval_claim.total_clawback_amount + @requested_claim.total_clawback_amount).format)
    end
    within("#completed-clawbacks") do
      expect(page).to have_table_row("All groups" => "Total", "Amount" => (@completed_claim.total_clawback_amount + @in_progress_claim.total_clawback_amount).format)
    end
  end

  def when_i_select_the_current_claim_window
    choose "#{I18n.l(@current_claim_window.starts_on, format: :long)} to #{I18n.l(@current_claim_window.ends_on, format: :long)}"
  end

  def then_i_see_zero_clawback_totals
    within("#pending-clawbacks") do
      expect(page).to have_table_row("All groups" => "Total", "Amount" => Money.new(0, "GBP").format)
    end
    within("#completed-clawbacks") do
      expect(page).to have_table_row("All groups" => "Total", "Amount" => Money.new(0, "GBP").format)
    end
  end

  def create_clawback(status, school, hours)
    claim = create(:claim, :submitted, status:, school:, claim_window: @historic_claim_window)
    create(:mentor_training, :not_assured, claim:, hours_completed: 10, hours_clawed_back: hours)
    claim
  end
end
