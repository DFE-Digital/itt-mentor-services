require "rails_helper"

RSpec.describe "School user views a retained provider assignment", service: :placements, type: :system do
  scenario "as a school user" do
    given_a_placement_assigned_to_a_provider
    when_i_sign_in_as_a_school_user
    then_i_can_view_but_not_remove_the_assignment
  end

  scenario "as a support user" do
    given_a_placement_assigned_to_a_provider
    when_i_sign_in_as_a_support_user
    then_i_can_view_but_not_remove_the_assignment
  end

  private

  def given_a_placement_assigned_to_a_provider
    @school = create(:placements_school, :primary)
    @provider = create(:placements_provider, name: "Aes Sedai Trust")
    @placement = create(:placement, school: @school, provider: @provider, academic_year: Placements::AcademicYear.current.next)
    @placement_attributes = @placement.attributes
    @school_attributes = @school.attributes
    @provider_attributes = @provider.attributes
  end

  def when_i_sign_in_as_a_school_user
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_sign_in_as_a_support_user
    sign_in_placements_support_user
  end

  def then_i_can_view_but_not_remove_the_assignment
    visit placements_school_placement_path(@school, @placement)
    expect(page).to have_title("#{@placement.decorate.title} - Manage school placements - GOV.UK")
    expect(page).to have_tag("Assigned to provider", "blue")
    expect(page).to have_summary_list_row("Provider", "Aes Sedai Trust")
    expect(page).not_to have_link("Remove", exact: true)
    expect(page).not_to have_button("Remove provider")
    expect(@placement.reload.attributes).to eq(@placement_attributes)
    expect(@school.reload.attributes).to eq(@school_attributes)
    expect(@provider.reload.attributes).to eq(@provider_attributes)
  end
end
