class Placements::Support::Schools::MentorsController < Placements::Support::ApplicationController
  before_action :set_school
  before_action :set_mentor, only: [:show]

  def index
    @pagy, @mentors = pagy(@school.mentors.order(:first_name, :last_name))
  end

  def show; end

  def index; end

  def new
    mentor_form
  end

  def check
    render :new unless mentor_form.valid?
  rescue TeachingRecord::RestClient::HttpError
    render :no_results
  end

  def create
    mentor_form.save!

    redirect_to placements_support_school_mentors_path(@school), flash: { success: t(".mentor_added") }
  end

  private

  def mentor_params
    params.require(:mentor_form)
          .permit(:first_name, :last_name, :trn)
          .merge(default_params)
  end

  def default_params
    { service: :placements, school: @school }
  end

  def mentor_form
    @mentor_form ||=
      if params[:mentor_form].present?
        MentorForm.new(mentor_params)
      else
        MentorForm.new(default_params)
      end
  end

  def set_school
    @school = Placements::School.find(params.fetch(:school_id))
  end

  def set_mentor
    @mentor = @school.mentors.find(params.fetch(:id))
  end
end
