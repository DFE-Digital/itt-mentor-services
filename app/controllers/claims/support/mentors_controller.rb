class Claims::Support::MentorsController < Claims::Support::ApplicationController
  before_action :authorize_mentor
  def search
    limit = search_params[:limit].to_i.clamp(25, 100)
    if search_params[:q].presence
      mentors = Mentor.where(
        "first_name ILIKE ? OR last_name ILIKE ? OR trn ILIKE ?",
        "%#{search_params[:q]}%",
        "%#{search_params[:q]}%",
        "%#{search_params[:q]}%",
      )
    end
    mentors ||= Mentor

    attributes = mentors
      .trained_in_academic_year(academic_year)
      .order_by_full_name
      .limit(limit).map do |mentor|
      { id: mentor.id, name: mentor.full_name, hint: mentor.trn }
    end

    render json: attributes.as_json
  end

  private

  def authorize_mentor
    authorize Claims::Mentor
  end

  def search_params
    params.permit(:q, :academic_year_id, :limit)
  end

  def academic_year
    @academic_year ||= AcademicYear.find(search_params[:academic_year_id])
  end
end
