class Claims::RequestClawbackWizard::CheckYourAnswersStep < BaseStep
  delegate :mentor_trainings, :steps, :step_name_for_mentor_training_clawback, :claim, to: :wizard
  delegate :school, to: :claim
  delegate :region_funding_available_per_hour, to: :school

  def mentor_training_clawback_data(mentor_training)
    steps.fetch(step_name_for_mentor_training_clawback(mentor_training))
  end

  def mentor_training_clawback_hours(mentor_training)
    mentor_training_clawback_data(mentor_training).number_of_hours.to_i
  end

  def mentor_training_clawback_amount(mentor_training)
    mentor_training_clawback_hours(mentor_training) * region_funding_available_per_hour
  end

  def mentor_training_clawback_reason(mentor_training)
    mentor_training_clawback_data(mentor_training).reason_for_clawback
  end

  def total_clawback_hours
    mentor_trainings.sum { |mentor_training| mentor_training_clawback_hours(mentor_training) }
  end

  def total_clawback_amount
    mentor_trainings.sum { |mentor_training| mentor_training_clawback_hours(mentor_training) * region_funding_available_per_hour }
  end
end
