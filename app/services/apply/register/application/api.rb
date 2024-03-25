module Apply
  module Register
    module Application
      class Api
        include ServicePattern

        def call
          response = HTTParty.get(url, headers:)
          JSON.parse(response.to_s)
        end

        private

        def url
          "#{ENV["APPLY_REGISTER_URL"]}/applications?recruitment_cycle_year=#{recruitment_cycle_year}"
        end

        def headers
          { "Authorization" => "Bearer #{ENV["APPLY_REGISTER_KEY"]}" }
        end

        def recruitment_cycle_year
          Time.current.year
        end
      end
    end
  end
end
