class Placements::Support::Schools::Users::AddUserController < Placements::Organisations::Users::AddUserController
  private

  def set_organisation
    school_id = params.require(:school_id)
    @organisation = Placements::School.find(school_id)
  end

  def step_path(step)
    add_user_placements_support_school_users_path(step:)
  end

  def index_path
    placements_support_school_users_path(@organisation)
  end
end
