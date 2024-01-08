class ProviderDecorator < OrganisationDecorator
  private

  def address_parts
    [
      street_address_1,
      street_address_2,
      street_address_3,
      town,
      city,
      county,
      postcode,
    ]
  end
end
