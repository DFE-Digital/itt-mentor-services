class Placements::MentorForm < MentorForm
  private

  def form_params_key
    "placements_mentor_form"
  end

  def mentor_builder
    Placements::MentorBuilder
  end
end
