require "rails_helper"

RSpec.describe "Non-support user signs in without DfE ID", service: :placements, type: :system do
  scenario do
    given_i_sign_in
    then_i_see_the_organisations_page
  end

  private

  def given_i_sign_in
    sign_in_placements_user(with_dfe_sign_id: false)
  end

  def then_i_see_the_organisations_page
    expect(page).to have_title("Organisations - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations")
  end
end
