class Placements::Placements::FilterForm < ApplicationForm
  include ActiveModel::Attributes

  attribute :school_ids, default: []
  attribute :subject_ids, default: []
  attribute :search_location, default: nil
  attribute :year_groups, default: []
  attribute :term_ids, default: []
  attribute :placements_to_show, default: "available_placements"
  attribute :academic_year_id, default: Placements::AcademicYear.current.id
  attribute :only_partner_schools, :boolean, default: false

  def initialize(provider, params = {})
    @provider = provider
    params.each_value { |v| v.compact_blank! if v.is_a?(Array) }

    super(params)
  end

  def filters_selected?
    attributes.except("placements_to_show", "academic_year_id").values.compact.flatten.any?
  end

  def clear_filters_path
    placements_provider_placements_path(
      @provider,
      filters: { placements_to_show:, academic_year_id: },
    )
  end

  def index_path_without_filter(filter:, value: nil)
    without_filter = if SINGULAR_ATTRIBUTES.include?(filter)
                       compacted_attributes.reject { |key, _| key == filter }
                     else
                       compacted_attributes.merge(filter => compacted_attributes[filter].reject { |filter_value| filter_value == value })
                     end

    placements_provider_placements_path(
      @provider,
      params: { filters: without_filter },
    )
  end

  def query_params
    {
      school_ids:,
      subject_ids:,
      year_groups:,
      only_partner_schools:,
      placements_to_show:,
      academic_year_id:,
      term_ids:,
      search_location:,
    }
  end

  def schools
    @schools ||= School.where(id: school_ids).order_by_name
  end

  def subjects
    @subjects ||= Subject.where(id: subject_ids).order_by_name
  end

  def terms
    @terms ||= Placements::Term.where(id: term_ids).order_by_term
  end

  private

  SINGULAR_ATTRIBUTES = %w[only_partner_schools placements_to_show search_location].freeze

  def compacted_attributes
    @compacted_attributes ||= attributes.compact_blank
  end
end
