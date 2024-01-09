class AccreditedProvider::Api
  include ServicePattern

  def initialize(link: nil)
    @link = link.presence || all_providers_url
  end

  attr_reader :link

  def call
    response = HTTParty.get(link)
    JSON.parse(response.to_s)
  end

  private

  def all_providers_url
    "#{ENV["PUBLISH_BASE_URL"]}/api/public/v1/recruitment_cycles/#{next_year}/providers?filter[is_accredited_body]=true"
  end

  def next_year
    Time.current.next_year.year
  end
end