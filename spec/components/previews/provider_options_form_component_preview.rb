class ProviderOptionsFormComponentPreview < ApplicationComponentPreview
  def less_than_15_providers
    providers = FactoryBot.build_list(:provider, 2)
    render(ProviderOptionsFormComponent.new(
             model: ProviderOnboardingForm.new,
             url: "",
             search_param: "Provider",
             providers: providers.map(&:decorate),
             back_link: "",
           ))
  end

  def more_than_15_providers
    providers = FactoryBot.build_list(:provider, 16)
    render(ProviderOptionsFormComponent.new(
             model: ProviderOnboardingForm.new,
             url: "",
             search_param: "Provider",
             providers: providers.map(&:decorate),
             back_link: "",
           ))
  end
end
