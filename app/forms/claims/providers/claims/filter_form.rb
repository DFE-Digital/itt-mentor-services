class Claims::Providers::Claims::FilterForm < ApplicationForm
  include ActiveModel::Attributes

  attribute :school_ids, default: []
  attribute :index_path

  def initialize(params = {})
    params[:school_ids].presence&.compact_blank!
    super(params)
  end

  def filters_selected?
    school_ids.present?
  end

  def index_path_without_filter(filter:, value: nil)
    without_filter = compacted_attributes.merge(
      filter => compacted_attributes[filter].reject { |filter_value| filter_value == value },
    )

    generate_path({ claims_providers_claims_filter_form: without_filter })
  end

  def clear_filters_path
    generate_path(claims_providers_claims_filter_form: {})
  end

  def clear_search_path
    index_path
  end

  def search
    nil
  end

  def schools
    @schools ||= Claims::School.find(school_ids)
  end

  def claim_windows
    []
  end

  def training_types
    []
  end

  def support_user_ids
    []
  end

  def mentor_ids
    []
  end

  def submitted_after
    nil
  end

  def submitted_before
    nil
  end

  def query_params
    {
      school_ids:,
    }
  end

  private

  def compacted_attributes
    @compacted_attributes ||= attributes.compact_blank.except("index_path")
  end

  def generate_path(args)
    return index_path if args.fetch(:claims_providers_claims_filter_form).compact_blank.blank?

    uri = URI(index_path)
    uri.query = args.to_query
    uri.to_s
  end
end
