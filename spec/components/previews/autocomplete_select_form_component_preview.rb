class AutocompleteSelectFormComponentPreview < ApplicationComponentPreview
  def school_onboarding_form
    current_user = FactoryBot.build(:claims_support_user)
    wizard = Claims::AddSchoolWizard.new(current_user:, state: {}, params: {})
    step = Claims::AddSchoolWizard::SchoolStep.new(
      wizard:, attributes: {},
    )
    render AutocompleteSelectFormComponent.new(
      model: step,
      scope: :school,
      url: "#",
      data: {
        turbo: false,
        controller: "autocomplete",
        autocomplete_path_value: "/api/school_suggestions",
        autocomplete_return_attributes_value: %w[town postcode],
        input_name: "school[name]",
      },
      input: {
        field_name: :id,
        value: nil,
        label: "Enter a school name, URN or postcode",
        caption: "Add organisation",
        previous_search: nil,
      },
    )
  end
end
