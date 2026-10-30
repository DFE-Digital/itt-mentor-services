require "rails_helper"

RSpec.describe "School user views placements without individual creation", service: :placements, type: :system do
  let(:with_school_contact) { true }
  let!(:school) { create(:placements_school, with_school_contact:) }

  scenario do
    given_i_am_signed_in
    when_i_visit_the_placements_page
    then_i_see_only_the_retained_creation_option
    and_the_school_records_have_not_changed
  end

  context "without a placement contact" do
    let(:with_school_contact) { false }

    scenario do
      given_i_am_signed_in
      when_i_visit_the_placements_page
      then_i_see_only_the_retained_creation_option
      and_the_school_records_have_not_changed
    end
  end

  context "when signed in as support" do
    scenario do
      given_i_am_signed_in_as_support
      when_i_visit_the_placements_page
      then_i_see_only_the_retained_creation_option
      and_the_school_records_have_not_changed
    end

    context "without a placement contact" do
      let(:with_school_contact) { false }

      scenario do
        given_i_am_signed_in_as_support
        when_i_visit_the_placements_page
        then_i_see_only_the_retained_creation_option
        and_the_school_records_have_not_changed
      end
    end
  end

  private

  def given_i_am_signed_in
    @school_attributes = school.attributes
    @hosting_interests = school.hosting_interests.map(&:attributes)
    sign_in_placements_user(organisations: [school])
  end

  def given_i_am_signed_in_as_support
    @school_attributes = school.attributes
    @hosting_interests = school.hosting_interests.map(&:attributes)
    sign_in_placements_support_user
  end

  def when_i_visit_the_placements_page
    visit placements_school_placements_path(school)
  end

  def then_i_see_only_the_retained_creation_option
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(page).to have_h1("Placements")
    expect(page).to have_link("Add multiple placements", href: new_add_multiple_placements_placements_school_placements_path(school))
    expect(page).not_to have_link("Add placement", exact: true)
    expect(page).not_to have_text("Before you add a placement, you must")
  end

  def and_the_school_records_have_not_changed
    expect(school.reload.attributes).to eq(@school_attributes)
    expect(school.hosting_interests.reload.map(&:attributes)).to eq(@hosting_interests)
    expect(school.placements).to be_empty
  end
end
