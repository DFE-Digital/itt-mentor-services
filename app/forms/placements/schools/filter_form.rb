class Placements::Schools::FilterForm < ApplicationForm
  include ActiveModel::Attributes

  attribute :schools_i_work_with_ids, default: []
  attribute :subject_ids, default: []
  attribute :search_location, default: nil
  attribute :search_by_name, default: nil
  attribute :phases, default: []
  attribute :year_groups, default: []
  attribute :itt_statuses, default: []
  attribute :last_offered_placements_academic_year_ids, default: []
  attribute :schools_to_show, default: "active"

  def initialize(provider, params = {})
    @provider = provider
    params.each_value { |v| v.compact_blank! if v.is_a?(Array) }

    super(params)
  end

  def filters_selected?
    attributes
      .except("schools_to_show")
      .values
      .compact
      .flatten
      .select(&:present?)
      .any?
  end

  def clear_filters_path
    placements_provider_find_index_path(@provider)
  end

  def index_path_without_filter(filter:, value: nil)
    without_filter = if SINGULAR_ATTRIBUTES.include?(filter)
                       compacted_attributes.reject { |key, _| key == filter }
                     else
                       compacted_attributes.merge(filter => compacted_attributes[filter].reject { |filter_value| filter_value == value })
                     end

    placements_provider_find_index_path(
      @provider,
      params: { filters: without_filter },
    )
  end

  def query_params
    {
      schools_i_work_with_ids:,
      subject_ids:,
      search_location:,
      search_by_name:,
      phases:,
      year_groups:,
      itt_statuses:,
      last_offered_placements_academic_year_ids:,
      schools_to_show:,
    }
  end

  def subjects
    @subjects ||= Subject.where(id: subject_ids).order_by_name
  end

  def year_group_options
    @year_group_options || Placement.year_groups_as_options.select do |year_group|
      year_groups.include?(year_group.value)
    end
  end

  def schools_i_work_with
    @schools_i_work_with ||= @provider.partner_schools.where(id: schools_i_work_with_ids).order_by_name
  end

  def last_offered_placements_academic_years
    Placements::AcademicYear.where(id: last_offered_placements_academic_year_ids)
  end

  def last_offered_placement_options
    Placements::AcademicYear.where(id: Placement.distinct.pluck(:academic_year_id))
                            .where("ends_on <= ?", Placements::AcademicYear.current.starts_on)
                            .order_by_date.pluck(:name, :id) << ["No recent placements", "never_offered"]
  end

  def primary_selected?
    phases.include?("Primary")
  end

  def secondary_selected?
    phases.include?("Secondary")
  end

  def primary_only?
    primary_selected? && !secondary_selected?
  end

  def secondary_only?
    !primary_selected? && secondary_selected?
  end

  private

  SINGULAR_ATTRIBUTES = %w[search_location search_by_name schools_to_show].freeze

  def compacted_attributes
    @compacted_attributes ||= attributes.compact_blank
  end
end
