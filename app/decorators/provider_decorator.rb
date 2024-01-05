class ProviderDecorator < OrganisationDecorator
  private

  def address_parts
    [
      address1,
      address2,
      address3,
      town,
      city,
      county,
      postcode,
    ]
  end
end
