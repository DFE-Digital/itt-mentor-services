# frozen_string_literal: true

# any additional details should be added to en.yml (t.personas.index)
PERSONAS = [
  { first_name: "Anne", last_name: "Wilson", email: "anne_wilson@example.org" },
  {
    first_name: "Patricia",
    last_name: "Adebayo",
    email: "patricia@example.com",
  },
  { first_name: "Mary", last_name: "Lawson", email: "mary@example.com" },
  {
    first_name: "Colin",
    last_name: "Chapman",
    email: "colin@example.com",
    support_user: true,
  },
].push((DEVELOPER_PERSONA if defined?(DEVELOPER_PERSONA))).compact.freeze

PERSONA_EMAILS = PERSONAS.map { |persona| persona[:email] }
