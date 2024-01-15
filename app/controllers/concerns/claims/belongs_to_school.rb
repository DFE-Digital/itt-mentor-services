module Claims::BelongsToSchool
  extend ActiveSupport::Concern

  included do
    before_action :set_school

    def set_school
      @school = Claims::School.find(params.require(:school_id))
    end
  end
end
