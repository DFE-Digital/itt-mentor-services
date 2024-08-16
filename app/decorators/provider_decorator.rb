class ProviderDecorator < OrganisationDecorator
  def town_and_postcode
    parts = [town, city, postcode].reject(&:blank?)
    parts.join(", ")
  end

  def partner_provider_placements(school)
    @partner_provider_placements ||= becomes(Placements::Provider).placements.where(school:).decorate
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
