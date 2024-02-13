module Dqt
  class Client
    class Request
      include HTTParty
      base_uri ENV.fetch("DQT_BASE_URL", "")
      headers "Accept" => "application/json",
              "Content-Type" => "application/json;odata.metadata=minimal",
              "Authorization" => "Bearer #{ENV.fetch("DQT_API_KEY", "")}",
              "X-Api-Version" => ENV.fetch("DQT_API_MINOR_VERSION", "20240101")
    end

    class HttpError < StandardError; end

    GET_SUCCESS = 200

    def self.get(path)
      response = Request.get(path)

      if response.code == GET_SUCCESS
        JSON.parse(response.body || "{}")
      else
        raise(HttpError, "status: #{response.code}, body: #{response.body}, headers: #{response.headers}")
      end
    end
  end
end
