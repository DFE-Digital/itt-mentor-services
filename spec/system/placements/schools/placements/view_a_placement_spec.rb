require "rails_helper"

RSpec.describe "Placements / Schools / Placements / View a placement", type: :system, service: :placements do
  let!(:school) { create(:placements_school, name: "School 1") }

  before do
    given_i_sign_in_as_anne
    visit placements_school_placement_path(school, placement)
  end

  context "when a placement has been fully completed and published" do
    let!(:placement, school:)

    context "when the placement has one subject assigned" do
      it "displays only the subject assigned to the placement" do
        given_
      end
    end
  end

  private

  def and_there_is_an_existing_user_for(user_name)
    user = create(:placements_user, user_name.downcase.to_sym)
    user_exists_in_dfe_sign_in(user:)
    and_user_has_one_school(user:)
  end

  def and_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def and_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def given_i_sign_in_as_anne
    and_there_is_an_existing_user_for("Anne")
    and_i_visit_the_sign_in_path
    and_i_click_sign_in
  end
end
