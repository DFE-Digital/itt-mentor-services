class Claims::Claim::FilterFormComponentPreview < ApplicationComponentPreview
  def default
    render Claims::Claim::FilterFormComponent.new(filter_form:)
  end

  def with_content
    render Claims::Claim::FilterFormComponent.new(filter_form:) do
      "Some content"
    end
  end

  def with_curated_providers
    render Claims::Claim::FilterFormComponent.new(
      filter_form:,
      providers: Claims::Provider.private_beta_providers,
    )
  end

  def with_curated_statuses
    render Claims::Claim::FilterFormComponent.new(
      filter_form:,
      statuses: %w[sampling_in_progress sampling_provider_not_approved sampling_not_approved],
    )
  end

  private

  def filter_form
    @filter_form ||= Claims::Support::Claims::FilterForm.new
  end
end
