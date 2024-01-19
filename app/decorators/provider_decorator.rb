class ProviderDecorator < OrganisationDecorator
  def town_and_postcode
    parts = [town, city, postcode].reject(&:blank?)
    parts.join(", ")
  end

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
