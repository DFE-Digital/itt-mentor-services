module GovUk::BankHoliday
  BASE_URI = "https://www.gov.uk/bank-holidays.json".freeze

  def self.all
    uri = URI.parse(BASE_URI)
    request = Net::HTTP::Get.new(uri.request_uri)

    response = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == "https",
      verify_mode: OpenSSL::SSL::VERIFY_PEER,
    ) do |http|
      http.request(request)
    end

    raise Net::HTTPError.new("Failed to fetch bank holidays: #{response.code}", response) unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).fetch("england-and-wales").fetch("events")
  end
end
