class Claims::MentorForm < MentorForm
  private

  def form_params_key
    "claims_mentor_form"
  end

  def mentor_builder
    Claims::MentorBuilder
  end
end
