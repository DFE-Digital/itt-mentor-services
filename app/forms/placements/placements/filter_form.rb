class Placements::Placements::FilterForm < ApplicationForm
  include ActiveModel::Attributes

  PHASES = [School::PRIMARY_PHASE, School::SECONDARY_PHASE].freeze

  attribute :school_phases, default: []
  attribute :school_ids, default: []
  attribute :subject_ids, default: []
  attribute :school_types, default: []
  attribute :genders, default: []
  attribute :religious_characters, default: []
  attribute :ofsted_ratings, default: []

  def initialize(params = {})
    params.each_value do |value|
      next unless value.is_a?(Array)

      value.compact_blank!
    end

    super(params)
  end

  def filters_selected?
    attributes.values.compact.flatten.any?
  end

  def clear_filters_path(provider)
    placements_provider_placements_path(provider)
  end

  def index_path_without_filter(provider:, filter:, value: nil)
    without_filter = compacted_attributes.merge(
      filter => compacted_attributes[filter].reject { |filter_value| filter_value == value },
    )

    placements_provider_placements_path(
      provider_id: provider,
      params: { filters: without_filter },
    )
  end

  def phases
    PHASES
  end

  def query_params
    {
      school_phases:,
      school_ids:,
      subject_ids:,
      school_types:,
      genders:,
      religious_characters:,
      ofsted_ratings:,
    }
  end

  def schools
    @schools ||= School.where(id: school_ids).order_by_name
  end

  def subjects
    @subjects ||= Subject.where(id: subject_ids).order_by_name
  end

  private

  def compacted_attributes
    @compacted_attributes ||= attributes.compact_blank
  end
end
