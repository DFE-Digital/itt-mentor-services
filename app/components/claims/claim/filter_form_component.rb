class Claims::Claim::FilterFormComponent < ApplicationComponent
  def initialize(
    filter_form:,
    statuses: Claims::Claim.statuses.values.without(*Claims::Claim::DRAFT_STATUSES.map(&:to_s)),
    academic_years: AcademicYear.where(id: Claims::ClaimWindow.select(:academic_year_id)).order_by_date,
    providers: nil,
    schools: nil,
    classes: [],
    html_attributes: {}
  )
    super(classes:, html_attributes:)

    @filter_form = filter_form
    @statuses = statuses
    @academic_years = academic_years
    @providers = providers || limit_records(Claims::Provider)
    @schools = schools || limit_records(Claims::School)
  end

  private

  attr_reader :claims, :filter_form

  def limit_records(klass)
    ids = Array(filter_form.public_send("#{klass.name.demodulize.underscore}_ids"))
    scope = klass.limit(25)

    if ids.present?
      extra_ids = klass.where.not(id: ids).limit(25 - ids.count).ids
      scope = klass.where(id: ids + extra_ids)
    end

    scope.order(:name)
  end
end
