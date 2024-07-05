class OptionsFormComponentPreview < ApplicationComponentPreview
  def less_than_15_schools
    schools = FactoryBot.build_list(:school, 2)
    render(OptionsFormComponent.new(
             model: SchoolOnboardingForm.new,
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
    render(OptionsFormComponent.new(
             model: SchoolOnboardingForm.new,
             scope: :school,
             url: "",
             search_param: "School",
             records: schools.map(&:decorate),
             records_klass: "school",
             back_link: "",
           ))
  end
end
