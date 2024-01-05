class AccreditedProvider::Api
  include ServicePattern

  def initialize(code: nil, updated_since: nil)
    @code = code
    @updated_since = updated_since
  end

  attr_reader :code, :updated_since

  def call
    response = if code.present?
                 HTTParty.get(provider_details_url(code))
               elsif updated_since.present?
                 HTTParty.get(updated_providers_url(updated_since))
               else
                 HTTParty.get(all_providers_url)
               end
    response = JSON.parse(response.to_s)
    response["data"]
  end

  private

  def all_providers_url
    "#{ENV["PUBLISH_BASE_URL"]}/api/public/v1/recruitment_cycles/#{next_year}/providers?filter[is_accredited_body]=true&per_page=500"
  end

  def updated_providers_url(updated_date)
    all_providers_url + "&filter[updated_since]=#{updated_date.iso8601}"
  end

  def provider_details_url(code)
    "#{ENV["PUBLISH_BASE_URL"]}/api/public/v1/recruitment_cycles/#{next_year}/providers/#{code}"
  end

  def next_year
    Time.current.next_year.year
  end
end
