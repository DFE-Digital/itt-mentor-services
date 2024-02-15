class SchoolOptionsFormComponentPreview < ApplicationComponentPreview
  def less_than_15_schools
    region = Region.new(name: "Rest of England",
                        claims_funding_available_per_hour_pence: 0,
                        claims_funding_available_per_hour_currency: "GBP")
    schools = FactoryBot.build_list(:school, 2, region:)
    render(SchoolOptionsFormComponent.new(
             model: SchoolOnboardingForm.new,
             url: "",
             search_param: "School",
             schools: schools.map(&:decorate),
             back_link: "",
           ))
  end

  def more_than_15_schools
    region = Region.new(name: "Rest of England",
                        claims_funding_available_per_hour_pence: 0,
                        claims_funding_available_per_hour_currency: "GBP")
    schools = FactoryBot.build_list(:school, 16, region:)
    render(SchoolOptionsFormComponent.new(
             model: SchoolOnboardingForm.new,
             url: "",
             search_param: "School",
             schools: schools.map(&:decorate),
             back_link: "",
           ))
  end
end
