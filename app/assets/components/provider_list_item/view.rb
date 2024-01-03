class ProviderListItem::View < GovukComponent::Base
  def initialize(provider:)
    @provider = provider
  end

  def call
    # TODO: Add Provider url
    render OrganisationListItem::View.new(
             organisation: @provider,
             organisation_url: "#",
             organisation_type: @provider.provider_type,
           )
  end
end
