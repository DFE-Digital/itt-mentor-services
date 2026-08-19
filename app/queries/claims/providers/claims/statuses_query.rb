class Claims::Providers::Claims::StatusesQuery
  def self.values
    status_colours.keys.map(&:to_s)
  end

  class << self
    private

    # The provider claims pages render Claim::ProviderStatusTagComponent inside the
    # provider card, so use that component as the source of truth for supported
    # statuses and their ordering.
    def status_colours
      Claim::ProviderStatusTagComponent.new(claim: Claims::Claim.new).send(:status_colours)
    end
  end
end
