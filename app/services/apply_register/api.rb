module ApplyRegister
  class Api < ApplicationService
    def initialize(year:, changed_since: nil)
      @year = year
      @changed_since = changed_since
    end

    def call
      response = HTTParty.get(all_applications_url,
                              headers: { "Authorization" => "Bearer #{ENV["APPLY_REGISTER_KEY"]}" },
                              query: query_params)
      JSON.parse(response.body)
    end

    private

    def query_params
      {
        recruitment_cycle_year: @year,
        changed_since: @changed_since,
      }
    end

    def all_applications_url
      "#{ENV["APPLY_REGISTER_URL"]}/applications"
    end
  end
end
