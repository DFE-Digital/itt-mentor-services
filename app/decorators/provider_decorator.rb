class ProviderDecorator < OrganisationDecorator
  def organisation_identifier_hint
    parts = [postcode, code].reject(&:blank?)
    parts.join(", ")
  end

  def partner_school_placements(school)
    @partner_school_placements ||= becomes(Placements::Provider).placements.where(school:).decorate
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
