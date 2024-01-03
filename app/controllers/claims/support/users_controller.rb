class Claims::Support::UsersController < Claims::Support::ApplicationController
  before_action :set_school

  def index
    @users = @school.users
  end

  private

  def set_school
    @school = Claims::School.find(params[:school_id])
  end
end
