class AccreditedProviderApi
  include ServicePattern

  def initialize(code = nil)
    @code = code
  end

  attr_reader :code

  def call
    code.present? ? provider_list(code) : provider_details
  end

  private

  def provider_list(code)
    Rails
      .cache
      .fetch("accredited_provider_details_#{code}", expires_in: 24.hours) do
        response = HTTParty.get(provider_details_url(code))
        response = JSON.parse(response.to_s)
        response["data"]
      end
  end

  def provider_details
    Rails
      .cache
      .fetch("all_accredited_providers", expires_in: 24.hours) do
        response = HTTParty.get(all_providers_url)
        response = JSON.parse(response.to_s)
        response["data"]
      end
  end

  def all_providers_url
    "#{ENV["PUBLISH_BASE_URL"]}/api/public/v1/recruitment_cycles/#{next_year}/providers?filter[is_accredited_body]=true"
  end

  def provider_details_url(code)
    "#{ENV["PUBLISH_BASE_URL"]}/api/public/v1/recruitment_cycles/#{next_year}/providers/#{code}"
  end

  def next_year
    Time.current.next_year.year
  end
end
