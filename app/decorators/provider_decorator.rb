class ProviderDecorator < OrganisationDecorator
  def organisation_identifier_hint(support_user)
    if support_user
      parts = [postcode, code].reject(&:blank?)
      parts.join(", ")
    else
      postcode
    end
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
