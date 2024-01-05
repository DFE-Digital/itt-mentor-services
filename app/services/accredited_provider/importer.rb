class AccreditedProvider::Importer
  include ServicePattern

  IMPORTABLE_KEYS = [
    "code",
    "name",
    "provider_type",
    "ukprn",
    "urn",
    "email",
    "telephone",
    "website",
    "street_address_1",
    "street_address_2",
    "street_address_3",
    "city",
    "country",
    "postcode",
  ].freeze

  def initialize(from_date = nil)
    @from_date = from_date
  end

  attr_reader :from_date

  def call
    errors = []
    accredited_providers = ::AccreditedProvider::Api.call
    accredited_providers.each do |provider_details|
      provider = generate_provider(provider_details)
      unless provider.save
        errors << provider_details.to_s
      end
    end

    if errors.any?
      Rails.logger.info "Invalid imports - #{errors.inspect}"
    end

    Rails.logger.info "Done!"
  end

  private

  def generate_provider(provider_details)
    api_provider_attributes = provider_details.fetch("attributes")
    import_attributes = api_provider_attributes.slice(*IMPORTABLE_KEYS)
    Provider.find_or_initialize_by(
      import_attributes,
    )
  end
end