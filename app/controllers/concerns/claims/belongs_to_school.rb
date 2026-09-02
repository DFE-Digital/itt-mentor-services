module Claims::BelongsToSchool
  extend ActiveSupport::Concern

  included do
    before_action :set_school

    def set_school
      @school = policy_scope(Claims::School).find(params.require(:school_id))
      session[:claims_current_school_id] = @school.id
    end
  end
end
