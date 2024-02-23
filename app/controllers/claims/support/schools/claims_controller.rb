class Claims::Support::Schools::ClaimsController < Claims::Support::ApplicationController
  include Claims::BelongsToSchool

  before_action :authorize_claim

  def index
    @claims = @school.claims.order("created_at DESC")
  end

  private

  def authorize_claim
    authorize Claim
  end
end
