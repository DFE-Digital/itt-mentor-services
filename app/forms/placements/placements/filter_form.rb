class Placements::Placements::FilterForm < ApplicationForm
  include ActiveModel::Attributes

  attribute :school_ids, default: []
  attribute :subject_ids, default: []
  attribute :school_types, default: []
  attribute :only_partner_schools, :boolean, default: false
  attribute :only_available_placements, :boolean, default: false

  def initialize(params = {})
    params.each_value { |v| v.compact_blank! if v.is_a?(Array) }

    super(params)
  end

  def filters_selected?
    attributes.values.compact.flatten.any?
  end

  def clear_filters_path(provider)
    placements_provider_placements_path(provider)
  end

  def index_path_without_filter(provider:, filter:, value: nil)
    without_filter = if BOOLEAN_ATTRIBUTES.include?(filter)
                       compacted_attributes.reject { |key, _| key == filter }
                     else
                       compacted_attributes.merge(filter => compacted_attributes[filter].reject { |filter_value| filter_value == value })
                     end

    placements_provider_placements_path(
      provider_id: provider,
      params: { filters: without_filter },
    )
  end

  def query_params
    {
      school_ids:,
      subject_ids:,
      school_types:,
      only_partner_schools:,
      only_available_placements:,
    }
  end

  def schools
    @schools ||= School.where(id: school_ids).order_by_name
  end

  def subjects
    @subjects ||= Subject.where(id: subject_ids).order_by_name
  end

  private

  BOOLEAN_ATTRIBUTES = %w[only_available_placements only_partner_schools].freeze

  def compacted_attributes
    @compacted_attributes ||= attributes.compact_blank
  end
end
