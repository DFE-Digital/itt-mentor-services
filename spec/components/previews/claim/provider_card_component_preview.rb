class Claim::ProviderCardComponentPreview < ApplicationComponentPreview
  def default
    render Claim::ProviderCardComponent.new(claim: build_claim(status: :sampling_in_progress), href: "", current_user:)
  end

  def amended
    render Claim::ProviderCardComponent.new(claim: build_claim(status: :sampling_provider_not_approved), href: "", current_user:)
  end

  def paid
    render Claim::ProviderCardComponent.new(claim: build_claim(status: :paid), href: "", current_user:)
  end

  private

  def current_user
    @current_user ||= FactoryBot.build_stubbed(:claims_provider_user)
  end

  def build_claim(status:)
    school = FactoryBot.create(
      :claims_school,
      urn: next_urn,
      name: "Riverbank Primary School",
      address1: "12 Orchard Lane",
      address2: "Westminster",
      town: "London",
      postcode: "SW1A 2AA",
      region: region,
    )

    claim = FactoryBot.create(
      :claim,
      :submitted,
      status:,
      school:,
      provider:,
      created_by: preview_user,
      submitted_by: preview_user,
      reference: next_reference,
      created_at: Time.zone.local(2025, 9, 5, 9, 0, 0),
    )

    mentor_one = FactoryBot.create(:claims_mentor, schools: [school])
    mentor_two = FactoryBot.create(:claims_mentor, schools: [school])

    FactoryBot.create(:mentor_training, claim:, provider:, mentor: mentor_one, hours_completed: 10)
    FactoryBot.create(:mentor_training, claim:, provider:, mentor: mentor_two, hours_completed: 8)

    claim
  end

  def region
    @region ||= Region.find_or_create_by!(name: "Inner London") do |record|
      record.claims_funding_available_per_hour_pence = 5_360
      record.claims_funding_available_per_hour_currency = "GBP"
    end
  end

  def provider
    @provider ||= FactoryBot.create(:claims_provider, code: "P#{SecureRandom.hex(3).upcase}")
  end

  def preview_user
    @preview_user ||= Claims::User.find_or_create_by!(email: "preview-claims-user@example.com") do |user|
      user.first_name = "Preview"
      user.last_name = "User"
      user.dfe_sign_in_uid = "preview-claims-user"
    end
  end

  def next_urn
    loop do
      urn = format("%06d", SecureRandom.random_number(1_000_000))
      return urn unless School.exists?(urn:)
    end
  end

  def next_reference
    loop do
      reference = (9_000_000 + SecureRandom.random_number(999_999)).to_s
      return reference unless Claims::Claim.exists?(reference:)
    end
  end
end
