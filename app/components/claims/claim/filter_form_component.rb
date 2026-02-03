class Claims::Claim::FilterFormComponent < ApplicationComponent
  UNASSIGNED = "unassigned".freeze

  def initialize(
    filter_form:,
    statuses: Claims::Claim.statuses.values.without(*Claims::Claim::DRAFT_STATUSES.map(&:to_s)),
    academic_years: AcademicYear.where(id: Claims::ClaimWindow.select(:academic_year_id)).order_by_date_desc,
    providers: nil,
    schools: nil,
    classes: [],
    html_attributes: {}
  )
    super(classes:, html_attributes:)

    @filter_form = filter_form
    @statuses = statuses
    @academic_years = academic_years
    @providers = providers || limit_records(Claims::Provider.accredited.excluding_niot_providers)
    @schools = schools || limit_records(Claims::School)
  end

  def mentors
    limit_records(
      Mentor.trained_in_academic_year(filter_form.academic_year),
      order: %i[first_name last_name],
    )
  end

  def support_users
    Claims::SupportUser.all.order_by_full_name
  end

  def training_types
    Claims::MentorTraining.training_types.keys.sort
  end

  def claim_windows
    filter_form.academic_year.claim_windows.decorate
  end

  private

  attr_reader :claims, :filter_form

  def limit_records(klass, order: :name)
    ids = Array(filter_form.public_send("#{klass.name.demodulize.underscore}_ids"))
    scope = klass.limit(25)

    if ids.present?
      extra_ids = klass.where.not(id: ids).limit(25 - ids.count).ids
      scope = klass.where(id: ids + extra_ids)
    end

    scope.order(order)
  end
end
