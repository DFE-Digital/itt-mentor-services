module TeachingRecord
  class RestClient
    class Request
      include HTTParty
      base_uri ENV.fetch("TEACHING_RECORD_BASE_URL", "")
      headers "Accept" => "application/json",
              "Content-Type" => "application/json;odata.metadata=minimal",
              "Authorization" => "Bearer #{ENV.fetch("TEACHING_RECORD_API_KEY", "")}",
              "X-Api-Version" => ENV.fetch("TEACHING_RECORD_API_MINOR_VERSION", "20240101")
    end

    class HttpError < StandardError; end

    def self.get(path)
      response = Request.get(path)

      if response.ok?
        JSON.parse(response.body || "{}")
      else
        raise(HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}")
      end
    end
  end
end
