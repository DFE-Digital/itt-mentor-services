class Placements::Schools::Users::AddUserController < Placements::Organisations::Users::AddUserController
  private

  def set_organisation
    @organisation = set_school
  end

  def step_path(step)
    add_user_placements_school_users_path(state_key:, step:)
  end

  def index_path
    placements_school_users_path(@organisation)
  end
end
