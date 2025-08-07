class Claims::Support::Claims::EditSentClawbackController < Claims::Support::Claims::EditRequestClawbackController
  def update
    if !@wizard.save_step
      render "edit"
    elsif @wizard.next_step.present?
      redirect_to step_path(@wizard.next_step)
    else
      @wizard.update_clawback
      @wizard.reset_state
      redirect_to index_path, flash: {
        heading: t(".success_heading"),
        body: t(".success_body_html", link: @wizard.audit_log_path),
      }
    end
  end

  private

  def set_wizard
    state = session[state_key] ||= {}
    current_step = params[:step]&.to_sym
    @wizard = Claims::EditSentClawbackWizard.new(claim: @claim, current_user:, params:, state:, mentor_training_id:, current_step:)
  end

  def step_path(step)
    edit_sent_clawback_claims_support_claims_clawback_path(claim: @claim, mentor_training_id:, state_key:, step:)
  end
end
