class Placements::Support::OrganisationsController < Placements::Support::ApplicationController
  def index
    @schools =
      Placements::School.includes(:gias_school).order("gias_schools.name")
    #  TODO: when we have more from the provider API....
    @providers = Provider.all
  end
end
