class Placements::Schools::SchoolContactsController < Placements::ApplicationController
  before_action :set_school
  before_action :set_school_contact, only: %i[edit update]

  def edit; end

  def update
    if @school_contact.update(school_contact_params)
      redirect_to placements_school_path(@school), flash: { success: t(".school_contact_updated") }
    else
      render :edit
    end
  end

  private

  def set_school
    @school = current_user.schools.find(params.require(:school_id))
  end

  def set_school_contact
    @school_contact = @school.school_contact
  end

  def school_contact_params
    params.require(:placements_school_contact)
      .permit(:first_name, :last_name, :email_address)
      .merge(school: @school)
  end
end
