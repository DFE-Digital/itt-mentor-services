RSpec.configure { |config| config.include FactoryBot::Syntax::Methods }

# Define global sequences for generating various types of identifiers that we need to use
FactoryBot.define do
  # UKPRNs are 8 character numeric strings beginning at 10000001
  # We treat them as strings because we never perform maths on them
  sequence(:ukprn) { |n| (10_000_000 + n).to_s }

  # URNs are 6 character numeric strings beginning at 100000
  sequence(:urn) { |n| (100_000 + n - 1).to_s }

  # Provider codes are 3 character alphanumeric strings – e.g. "T92"
  sequence(:provider_code) { |n| n.to_s(36).rjust(3, "0").upcase }
end
