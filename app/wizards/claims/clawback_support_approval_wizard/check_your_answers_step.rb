class Claims::ClawbackSupportApprovalWizard::CheckYourAnswersStep < BaseStep
  delegate :claim, :step_name_for_approval, :mentor_trainings, to: :wizard

  def clawback_approved?(mentor_training)
    @wizard.steps.fetch(
      step_name_for_approval(mentor_training),
    ).approved == Claims::ClawbackSupportApprovalWizard::ApprovalStep::YES
  end
end
