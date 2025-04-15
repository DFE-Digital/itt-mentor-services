class Placements::AcademicYearsController < Placements::ApplicationController
  def edit
    @selected_academic_year = current_user.selected_academic_year
    @academic_year_options = academic_year_options
  end

  def update
    if current_user.update(selected_academic_year:)
      success_path = if current_user.support_user?
                       support_root_path
                     else
                       organisations_path
                     end

      redirect_to success_path, flash: {
        heading: t(".heading"),
        body: t(".body_html", selected_academic_year_name: selected_academic_year.name),
      }
    else
      render :edit
    end
  end

  private

  def academic_year_options
    option = Struct.new(:id, :name)
    [
      option.new(id: current_academic_year.id, name: current_academic_year.display_name),
      option.new(id: next_academic_year.id, name: next_academic_year.display_name),
    ]
  end

  def current_academic_year
    @current_academic_year ||= Placements::AcademicYear.current.decorate
  end

  def next_academic_year
    @next_academic_year || current_academic_year.next.decorate
  end

  def academic_year_params
    params.require(:placements_user).permit(:selected_academic_year_id)
  end

  def selected_academic_year
    Placements::AcademicYear.find(academic_year_params.fetch(:selected_academic_year_id))
  end
end
