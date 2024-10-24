class Claims::Claim::FilterFormComponent < ApplicationComponent
  def initialize(
    filter_form:,
    statuses: Claims::Claim.statuses.keys,
    academic_years: AcademicYear.where(id: Claims::ClaimWindow.select(:academic_year_id)).order_by_date,
    providers: Claims::Provider.all,
    schools: Claims::School.all,
    classes: [],
    html_attributes: {}
  )
    super(classes:, html_attributes:)

    @filter_form = filter_form
    @statuses = statuses
    @academic_years = academic_years
    @providers = providers
    @schools = schools
  end

  private

  attr_reader :claims, :filter_form
end
