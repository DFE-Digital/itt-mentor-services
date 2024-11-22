module Claims::Claim::Referencable
  extend ActiveSupport::Concern

  included do
    def generate_reference
      loop do
        reference = SecureRandom.random_number(99_999_999)

        break reference unless Claims::Claim.exists?(reference:)
      end
    end
  end
end
