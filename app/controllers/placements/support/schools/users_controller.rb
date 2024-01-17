class Placements::Support::Schools::UsersController < Placements::Support::Organisations::UsersController
  private

  def set_organisation
    @organisation = @school = Placements::School.find(params[:school_id])
  end

  def redirect_to_index
    redirect_to placements_support_school_users_path(@school)
  end
end
