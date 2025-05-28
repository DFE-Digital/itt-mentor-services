require "rails_helper"

RSpec.describe "Non-support user signs in without DfE ID", service: :placements, type: :system do
  scenario do
    given_i_sign_in
    then_i_do_not_have_access_to_the_service
  end

  private

  def given_i_sign_in
    sign_in_placements_user(with_dfe_sign_id: false)
  end

  def then_i_do_not_have_access_to_the_service
    expect(page).to have_important_banner("You do not have access to this service")
  end
end
