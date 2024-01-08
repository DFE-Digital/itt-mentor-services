class Claims::Support::ClaimsController < Claims::Support::ApplicationController
  before_action :set_school, only: [:index]

  def index; end

  private

  def set_school
    @school = School.find(params.require(:school_id))
  end
end
