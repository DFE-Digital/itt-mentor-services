require "rails_helper"

RSpec.describe "School user views existing potential-placement details", service: :placements, type: :system do
  scenario "with primary, secondary and SEND details" do
    given_a_school_with_potential_placement_details_exists
    when_i_sign_in
    then_i_see_the_existing_potential_placement_details
    and_i_cannot_edit_the_potential_placement_details
    and_the_stored_details_are_unchanged
  end

  scenario "with unknown placement selections" do
    given_a_school_with_potential_placement_details_exists
    and_the_placement_selections_are_unknown
    when_i_sign_in
    then_i_see_the_unknown_placement_selections
    and_i_cannot_edit_the_potential_placement_details
    and_the_stored_details_are_unchanged
  end

  private

  def given_a_school_with_potential_placement_details_exists
    english = create(:subject, :secondary, name: "English")
    key_stage_2 = create(:key_stage, name: "Key stage 2")
    @potential_placement_details = {
      "phase" => { "phases" => %w[Primary Secondary] },
      "year_group_selection" => { "year_groups" => %w[year_2] },
      "year_group_placement_quantity" => { "year_2" => 2 },
      "secondary_subject_selection" => { "subject_ids" => [english.id] },
      "secondary_placement_quantity" => { "english" => 3 },
      "key_stage_selection" => { "key_stage_ids" => [key_stage_2.id] },
      "key_stage_placement_quantity" => { "key_stage_2" => 1 },
      "note_to_providers" => { "note" => "Please contact us to discuss placements." },
    }
    hosting_interest = build(:hosting_interest, :for_next_year, appetite: "interested")
    @school = create(
      :placements_school,
      name: "Example Primary School",
      hosting_interests: [hosting_interest],
      potential_placement_details: @potential_placement_details,
    )
  end

  def and_the_placement_selections_are_unknown
    @potential_placement_details["year_group_selection"] = { "year_groups" => %w[unknown] }
    @potential_placement_details["secondary_subject_selection"] = { "subject_ids" => %w[unknown] }
    @potential_placement_details["key_stage_selection"] = { "key_stage_ids" => %w[unknown] }
    @school.update!(potential_placement_details: @potential_placement_details)
  end

  def when_i_sign_in
    sign_in_placements_user(organisations: [@school])
  end

  def then_i_see_the_existing_potential_placement_details
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements you may be able to offer")
    expect(page).to have_h2("Your potential placements")
    expect(page).to have_summary_list_row("Potential phases", "Primary Secondary")
    within("#primary_placements") do
      expect(page).to have_summary_list_row("Year 2", "2")
    end
    within("#secondary_placements") do
      expect(page).to have_summary_list_row("English", "3")
    end
    within("#send_placements") do
      expect(page).to have_summary_list_row("Key stage 2", "1")
    end
    expect(page).to have_summary_list_row("Message to providers", "Please contact us to discuss placements.")
    expect(page).to have_link("add your placements")
  end

  def then_i_see_the_unknown_placement_selections
    expect(page).to have_h1("Placements you may be able to offer")
    %w[primary_placements secondary_placements send_placements].each do |id|
      within("##{id}") do
        expect(page).to have_summary_list_row("I don’t know", "Not entered")
      end
    end
  end

  def and_i_cannot_edit_the_potential_placement_details
    %w[education_phases primary_placements secondary_placements send_placements message_to_providers].each do |id|
      within("##{id}") do
        expect(page).not_to have_link("Change")
      end
    end
  end

  def and_the_stored_details_are_unchanged
    expect(@school.reload.potential_placement_details).to eq(@potential_placement_details)
  end
end
