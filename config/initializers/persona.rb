# frozen_string_literal: true

CLAIMS_PERSONAS = [
  {
    first_name: "Anne",
    last_name: "Wilson",
    email: "anne_wilson@example.org",
    service: :claims,
  },
  {
    first_name: "Mary",
    last_name: "Lawson",
    email: "mary@example.com",
    service: :claims,
  },
  {
    first_name: "Colin",
    last_name: "Chapman",
    email: "colin@example.com",
    support_user: true,
    service: :claims,
  },
].freeze

PLACEMENTS_PERSONAS = [
  {
    first_name: "Anne",
    last_name: "Wilson",
    email: "anne_wilson@example.org",
    service: :placements,
  },
  {
    first_name: "Patricia",
    last_name: "Adebayo",
    email: "patricia@example.com",
    service: :placements,
  },
  {
    first_name: "Mary",
    last_name: "Lawson",
    email: "mary@example.com",
    service: :placements,
  },
  {
    first_name: "Colin",
    last_name: "Chapman",
    email: "colin@example.com",
    support_user: true,
    service: :placements,
  },
].freeze

# any additional details should be added to en.yml (t.personas.index)
PERSONAS = [
  *CLAIMS_PERSONAS,
  *PLACEMENTS_PERSONAS,
  (DEVELOPER_PERSONA if defined?(DEVELOPER_PERSONA)),
].compact.freeze

PERSONA_EMAILS = PERSONAS.map { |persona| persona[:email] }
