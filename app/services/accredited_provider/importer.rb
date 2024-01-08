class AccreditedProvider::Importer
  include ServicePattern

  IMPORTABLE_KEYS = %w[
    code
    name
    provider_type
    ukprn
    urn
    email
    telephone
    website
    street_address_1
    street_address_2
    street_address_3
    city
    county
    postcode
  ].freeze

  def initialize(updated_since: nil)
    @updated_since = updated_since
  end

  attr_reader :updated_since

  def call
    errors = []
    accredited_providers = ::AccreditedProvider::Api.call(updated_since:)
    accredited_providers.each do |provider_details|
      provider = generate_provider(provider_details)
      unless provider.save
        errors << provider.inspect + "Errors: #{provider.errors.full_messages.join(",")}"
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
