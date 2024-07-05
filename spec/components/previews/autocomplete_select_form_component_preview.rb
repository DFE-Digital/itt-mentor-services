class AutocompleteSelectFormComponentPreview < ApplicationComponentPreview
  def school_onboarding_form
    render AutocompleteSelectFormComponent.new(
      model: SchoolOnboardingForm.new,
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
