class Claims::Support::Schools::ClaimsController < Claims::Support::ApplicationController
  include Claims::BelongsToSchool

  def index
    @claims = @school.claims.order("created_at DESC")
  end
end
