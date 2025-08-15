class Claims::ClawbackSupportApprovalWizard::ApprovalStep < BaseStep
  attribute :mentor_training_id
  attribute :approved
  attribute :reason_clawback_rejected

  delegate :claim, to: :wizard

  YES = "Yes".freeze
  NO = "No".freeze
  OPTIONS = [YES, NO].freeze

  validates :approved, presence: true, inclusion: { in: OPTIONS }
  validates :reason_clawback_rejected, presence: true, if: ->(step) { step.approved == NO }

  def options_for_selection
    [
      OpenStruct.new(name: YES),
      OpenStruct.new(name: NO),
    ]
  end

  def mentor_training
    @mentor_training ||= Claims::MentorTraining.find(mentor_training_id)
  end
end
