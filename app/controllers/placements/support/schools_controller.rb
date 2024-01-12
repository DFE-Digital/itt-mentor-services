class Placements::Support::SchoolsController < Placements::Support::ApplicationController
  def new
    @school_form = SchoolOnboardingForm.new
  end

  def check
    if school_form.valid?
      @school = school
    else
      render :new
    end
  end

  def create
    if school_form.onboard
      redirect_to placements_support_organisations_path
    else
      render :new
    end
  end

  def show
    @school = Placements::School.find(params[:id]).decorate
  end

  private

  def school_form
    @school_form ||= SchoolOnboardingForm.new(urn: urn_param, service: :placements)
  end

  def school
    @school ||= school_form.school.decorate
  end

  def urn_param
    params.dig(:school, :search_urn)
  end
end
