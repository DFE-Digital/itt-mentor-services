class Claims::Claim::FilterFormComponent < ApplicationComponent
  def initialize(
    filter_form:,
    academic_years: AcademicYear.where(id: Claims::ClaimWindow.select(:academic_year_id)).order_by_date,
    statuses: Claims::Claim.statuses.values.without(*Claims::Claim::DRAFT_STATUSES.map(&:to_s)),
    providers: Claims::Provider.all,
    classes: [],
    html_attributes: {}
  )
    super(classes:, html_attributes:)

    @filter_form = filter_form
    @academic_years = academic_years
    @statuses = statuses
    @schools = Claims::School.all
    @providers = providers
  end

  private

  attr_reader :claims, :filter_form
end
