class Placements::Schools::UsersController < Placements::Organisations::UsersController
  private

  def set_organisation
    @organisation = set_school
  end

  def redirect_to_index
    redirect_to placements_school_users_path(@organisation)
  end
end
