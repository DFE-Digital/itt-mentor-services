class Claims::Support::Claims::ClaimActivitiesController < Claims::Support::ApplicationController
  def index
    @pagy, @claim_activities = pagy(Claims::ClaimActivity.order(created_at: :desc))

    authorize [:claims, @claim_activities]
  end

  def show
    @claim_activity = Claims::ClaimActivity.find(params[:id])

    if @claim_activity.sampling_uploaded?
      @pagy, @provider_samplings = pagy(@claim_activity.record.provider_samplings.order_by_provider_name)
    end

    authorize [:claims, @claim_activity]
  end
end
