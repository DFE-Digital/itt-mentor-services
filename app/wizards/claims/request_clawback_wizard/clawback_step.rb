class Claims::RequestClawbackWizard::ClawbackStep < BaseStep
  attribute :number_of_hours, :integer
  attribute :reason_for_clawback

  validates :number_of_hours, presence: true, numericality: { only_integer: true, less_than_or_equal_to: 40 }
  validates :reason_for_clawback, presence: true

  # TODO: Add methods for assigning attributes to relevant clawback fields on the claim model instance
  # TODO: Add tailored error messages to activerecord yml file when attributes are in use
end
