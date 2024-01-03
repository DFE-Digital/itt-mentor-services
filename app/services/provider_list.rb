class ProviderList
  include ServicePattern

  def initialize(provider_codes: nil, order_by: :name)
    @provider_codes = provider_codes || Provider.all.pluck(:provider_code)
    @order_by = order_by
  end

  def call
    providers =
      all_providers.filter do |provider|
        @provider_codes.include? provider.dig("attributes", "code")
      end
    providers = providers.map { |provider| provider["attributes"] }
    providers.sort_by { |provider| provider[@order_by.to_s] }
  end

  private

  def all_providers
    @all_providers ||= AccreditedProviderApi.call
  end
end
