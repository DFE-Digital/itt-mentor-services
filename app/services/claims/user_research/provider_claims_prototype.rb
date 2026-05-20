class Claims::UserResearch::ProviderClaimsPrototype
  ProviderProfile = Struct.new(:code, :name, :email, keyword_init: true)
  ClaimRecord = Struct.new(
    :id,
    :reference,
    :school_name,
    :status,
    :submitted_on,
    :academic_year,
    :mentor_count,
    :amount,
    keyword_init: true,
  )

  PROVIDERS = {
    "BPN01" => ProviderProfile.new(
      code: "BPN01",
      name: "Test provider",
      email: "research+test-provider@example.org",
    ),
    "NIOT1" => ProviderProfile.new(
      code: "NIOT1",
      name: "National Institute of Teaching",
      email: "research+niot@example.org",
    ),
  }.freeze

  CLAIMS = {
    "BPN01" => [
      ClaimRecord.new(
        id: "proto-claim-9001",
        reference: "90000001",
        school_name: "Shelbyville Elementary",
        status: "Audit requested",
        submitted_on: Date.new(2026, 4, 22),
        academic_year: "2025 to 2026",
        mentor_count: 3,
        amount: "GBP 1,125.00",
      ),
      ClaimRecord.new(
        id: "proto-claim-9002",
        reference: "90000002",
        school_name: "Springfield High",
        status: "Audit requested",
        submitted_on: Date.new(2026, 4, 24),
        academic_year: "2025 to 2026",
        mentor_count: 2,
        amount: "GBP 750.00",
      ),
      ClaimRecord.new(
        id: "proto-claim-9003",
        reference: "90000003",
        school_name: "Riverdale Academy",
        status: "Submitted",
        submitted_on: Date.new(2026, 4, 25),
        academic_year: "2025 to 2026",
        mentor_count: 4,
        amount: "GBP 1,500.00",
      ),
    ],
    "NIOT1" => [
      ClaimRecord.new(
        id: "proto-claim-2001",
        reference: "2001",
        school_name: "Riverdale Academy",
        status: "Payment in progress",
        submitted_on: Date.new(2026, 4, 21),
        academic_year: "2025 to 2026",
        mentor_count: 4,
        amount: "GBP 1,500.00",
      ),
    ],
  }.freeze

  def provider_for(code:, email: nil)
    provider = PROVIDERS[normalize(code)]
    return if provider.nil?
    return provider if email.nil?

    provider if provider.email.casecmp?(normalize(email))
  end

  def claims_for(code)
    CLAIMS.fetch(normalize(code), [])
  end

  def find_claim(code:, id:)
    claims_for(code).find { |claim| claim.id == id }
  end

  private

  def normalize(value)
    value.to_s.strip.upcase
  end
end
