# frozen_string_literal: true

CLAIMS_PERSONAS = [
  {
    first_name: "Anne",
    last_name: "Wilson",
    email: "anne_wilson@example.org",
    type: "Claims::User",
  },
  {
    first_name: "Mary",
    last_name: "Lawson",
    email: "mary@example.com",
    type: "Claims::User",
  },
  {
    first_name: "Colin",
    last_name: "Chapman",
    email: "colin.chapman@education.gov.uk",
    type: "Claims::SupportUser",
  },
].freeze

PLACEMENTS_PERSONAS = [
  {
    first_name: "Anne",
    last_name: "Wilson",
    email: "anne_wilson@example.org",
    type: "Placements::User",
  },
  {
    first_name: "Patricia",
    last_name: "Adebayo",
    email: "patricia@example.com",
    type: "Placements::User",
  },
  {
    first_name: "Mary",
    last_name: "Lawson",
    email: "mary@example.com",
    type: "Placements::User",
  },
  {
    first_name: "Colin",
    last_name: "Chapman",
    email: "colin.chapman@education.gov.uk",
    type: "Placements::SupportUser",
  },
].freeze

# any additional details should be added to en.yml (t.personas.index)
PERSONAS = [
  *CLAIMS_PERSONAS,
  *PLACEMENTS_PERSONAS,
  (DEVELOPER_PERSONA if defined?(DEVELOPER_PERSONA)),
].compact.freeze

PERSONA_EMAILS = PERSONAS.map { |persona| persona[:email] }
