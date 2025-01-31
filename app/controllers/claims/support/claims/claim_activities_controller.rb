class Claims::Support::Claims::ClaimActivitiesController < Claims::Support::ApplicationController
  def index
    claim_activities = Claims::ClaimActivity.order(created_at: :desc)
    authorize [:claims, claim_activities]

    @pagy, @claim_activities = pagy(claim_activities)
    @claim_activities = @claim_activities.decorate
  end

  def show
    authorize [:claims, claim_activity]

    if claim_activity.sampling_uploaded?
      @pagy, @provider_samplings = pagy(claim_activity.record.provider_samplings.order_by_provider_name)
    end

    @claim_activity = claim_activity.decorate
  end

  def resend_payer_email
    authorize [:claims, claim_activity]
    case claim_activity.action
    when "payment_request_delivered"
      Claims::Payment::ResendEmail.call(payment: claim_activity.record)
    when "clawback_request_delivered"
      Claims::Clawback::ResendEmail.call(clawback: claim_activity.record)
    else
      raise "Unknown action: #{claim_activity.action}"
    end

    redirect_to claims_support_claims_claim_activity_path(claim_activity), flash: { success: true, heading: t(".success") }
  end

  def resend_provider_email
    authorize [:claims, claim_activity]
    Claims::Sampling::ResendEmails.call(provider_sampling:)

    redirect_to claims_support_claims_claim_activity_path(claim_activity), flash: { success: true, heading: t(".success", provider_name: provider_sampling.provider_name) }
  end

  private

  def claim_activity
    @claim_activity ||= Claims::ClaimActivity.find(params[:id])
  end

  def provider_sampling
    @provider_sampling ||= claim_activity.record.provider_samplings.find(params[:provider_sampling_id])
  end
end
