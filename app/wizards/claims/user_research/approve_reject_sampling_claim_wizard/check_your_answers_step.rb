class Claims::UserResearch::ApproveRejectSamplingClaimWizard::CheckYourAnswersStep < BaseStep
  delegate :mentor_training_steps, :claim, :mentor_trainings, :action, to: :wizard

  def action_heading
    if action == "approve"
      "Approve this claim"
    else
      "Reject this claim"
    end
  end
end
