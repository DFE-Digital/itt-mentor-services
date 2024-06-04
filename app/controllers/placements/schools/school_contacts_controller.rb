class Placements::Schools::SchoolContactsController < Placements::ApplicationController
  before_action :set_school
  before_action :set_school_contact, only: %i[edit update]

  def new
    @school_contact = if params[:placements_school_contact].present?
                        Placements::SchoolContact.new(school_contact_params)
                      else
                        Placements::SchoolContact.new(school: @school)
                      end
  end

  def check
    @school_contact = Placements::SchoolContact.new(school_contact_params)
    if @school_contact.valid?
      @back_link = @change_link = new_placements_school_school_contact_path(
        school_id: @school.id,
        placements_school_contact: {
          first_name: @school_contact.first_name,
          last_name: @school_contact.last_name,
          email_address: @school_contact.email_address,
        },
      )
    else
      render :new
    end
  end

  def create
    @school_contact = Placements::SchoolContact.new(school_contact_params)
    @school_contact.save!

    redirect_to placements_school_path(@school), flash: { success: t(".school_contact_added") }
  end

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
