class Placements::EditHostingInterestWizard::UnableToChangeStep < BaseStep
  delegate :school, :current_user, to: :wizard
  delegate :placements, to: :school

  def assigned_placements
    @assigned_placements ||= placements
      .unavailable_placements_for_academic_year(current_user.selected_academic_year)
      .decorate
  end
end
