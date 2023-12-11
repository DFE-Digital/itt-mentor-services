# frozen_string_literal: true

# any additional details should be added to en.yml (t.personas.index)
PERSONAS = [
  { first_name: "Anne", last_name: "Wilson", email: "anne_wilson@example.org" }
].push((DEVELOPER_PERSONA if defined?(DEVELOPER_PERSONA))).compact.freeze

PERSONA_EMAILS = PERSONAS.map { |persona| persona[:email] }
