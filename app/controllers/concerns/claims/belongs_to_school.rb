module Claims::BelongsToSchool
  extend ActiveSupport::Concern

  included do
    before_action :set_school

    def set_school
      @school = scoped_schools.find(params.require(:school_id))
    rescue ActiveRecord::RecordNotFound
      redirect_to not_found_path
    end

    def scoped_schools
      return Claims::School.all if current_user.support_user?

      current_user.schools
    end
  end
end
