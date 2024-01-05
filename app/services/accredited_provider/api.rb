class AccreditedProvider::Api
  include ServicePattern

  def call
    response = HTTParty.get(all_providers_url)
    response = JSON.parse(response.to_s)
    response["data"]
  end

  private

  def all_providers_url
    "#{ENV["PUBLISH_BASE_URL"]}/api/public/v1/recruitment_cycles/#{next_year}/providers?filter[is_accredited_body]=true&per_page=500"
  end

  def next_year
    Time.current.next_year.year
  end
end
