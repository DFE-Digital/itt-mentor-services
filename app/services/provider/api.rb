class Provider::Api
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
    "#{ENV["PUBLISH_BASE_URL"]}/api/public/v1/recruitment_cycles/#{recruitment_cycle_year}/providers"
  end

  # Recruitment cycle year calculated based on the cycle timetime
  # https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/app/services/cycle_timetable.rb
  def recruitment_cycle_year
    current_year = Time.current.year
    next_year = current_year + 1
    cycle_start =  Time.zone.local(current_year, 10, 1) # Start of October
    cycle_start += 1.day until cycle_start.wday == 2 # First Tuesday of October
    Time.current > cycle_start ? next_year : current_year
  end
end
