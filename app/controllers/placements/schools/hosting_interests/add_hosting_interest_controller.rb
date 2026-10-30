class Placements::Schools::HostingInterests::AddHostingInterestController < Placements::ApplicationController
  before_action :set_school

  def whats_next
    @current_navigation = if request.referer.match("hosting_interests\/[a-zA-Z0-9-]*\/edit")
                            :organisation_details
                          else
                            :placements
                          end

    return if appetite == "not_open"

    @placement_details = session["whats_next"].presence || @school.potential_placement_details
  end

  private

  def appetite
    @appetite ||= next_academic_year_hosting_interest&.appetite
  end

  def next_academic_year_hosting_interest
    @next_academic_year_hosting_interest ||= @school
      .reload
      .hosting_interests
      .for_academic_year(Placements::AcademicYear.current.next)
      .last
  end
end
