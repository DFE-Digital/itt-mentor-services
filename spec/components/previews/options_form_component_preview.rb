class OptionsFormComponentPreview < ApplicationComponentPreview
  def less_than_15_schools
    schools = FactoryBot.build_list(:school, 2)
    wizard = Claims::AddSchoolWizard.new(state: {}, params: {})
    step = Claims::AddSchoolWizard::SchoolOptionsStep.new(
      wizard:, attributes: {},
    )
    render(OptionsFormComponent.new(
             model: step,
             scope: :school,
             url: "",
             search_param: "School",
             records: schools.map(&:decorate),
             records_klass: "school",
             back_link: "",
           ))
  end

  def more_than_15_schools
    schools = FactoryBot.build_list(:school, 16)
    wizard = Claims::AddSchoolWizard.new(state: {}, params: {})
    step = Claims::AddSchoolWizard::SchoolOptionsStep.new(
      wizard:, attributes: {},
    )
    render(OptionsFormComponent.new(
             model: step,
             scope: :school,
             url: "",
             search_param: "School",
             records: schools.map(&:decorate),
             records_klass: "school",
             back_link: "",
           ))
  end
end
