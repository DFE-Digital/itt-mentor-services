class Claims::Support::Claims::FilterForm < ApplicationForm
  include ActiveModel::Attributes

  attribute :search
  attribute :search_school
  attribute :search_provider
  attribute "submitted_after(1i)"
  attribute "submitted_after(2i)"
  attribute "submitted_after(3i)"
  attribute "submitted_before(1i)"
  attribute "submitted_before(2i)"
  attribute "submitted_before(3i)"
  attribute :school_ids, default: []
  attribute :provider_ids, default: []
  attribute :statuses, default: []
  attribute :academic_year_id, default: -> { AcademicYear.for_latest_claim_window.id }
  attribute :mentor_ids, default: []
  attribute :support_user_ids, default: []
  attribute :training_types, default: []

  attribute :index_path

  def initialize(params = {})
    params[:school_ids].compact_blank! if params[:school_ids].present?
    params[:provider_ids].compact_blank! if params[:provider_ids].present?

    super(params)
  end

  def filters_selected?
    school_ids.present? ||
      provider_ids.present? ||
      submitted_after.present? ||
      submitted_before.present? ||
      statuses.present? ||
      mentor_ids.present? ||
      support_user_ids.present? ||
      training_types.present?
  end

  def index_path_without_filter(filter:, value: nil)
    without_filter = compacted_attributes.merge(
      filter => compacted_attributes[filter].reject { |filter_value| filter_value == value },
    )

    generate_path({ claims_support_claims_filter_form: without_filter })
  end

  def index_path_without_submitted_dates(filter)
    without_filter = compacted_attributes.except(
      "#{filter}(1i)",
      "#{filter}(2i)",
      "#{filter}(3i)",
    )

    generate_path({ claims_support_claims_filter_form: without_filter })
  end

  def clear_filters_path
    generate_path(claims_support_claims_filter_form: { search: })
  end

  def clear_search_path
    generate_path(claims_support_claims_filter_form: compacted_attributes.except("search"))
  end

  def schools
    @schools ||= Claims::School.find(school_ids)
  end

  def providers
    @providers ||= Claims::Provider.find(provider_ids)
  end

  def academic_year
    @academic_year ||= AcademicYear.find(academic_year_id)
  end

  def mentors
    @mentors ||= Mentor.find(mentor_ids)
  end

  def support_users
    @support_users ||= Claims::SupportUser.find(support_user_ids.reject do |id|
      id == Claims::Claim::FilterFormComponent::UNASSIGNED
    end)
  end

  def query_params
    {
      search:,
      search_school:,
      search_provider:,
      school_ids:,
      provider_ids:,
      submitted_after:,
      submitted_before:,
      statuses:,
      academic_year_id:,
      mentor_ids:,
      support_user_ids:,
      training_types:,
    }
  end

  def submitted_after
    Date.new(
      attributes["submitted_after(1i)"].to_i, # year
      attributes["submitted_after(2i)"].to_i, # month
      attributes["submitted_after(3i)"].to_i, # day
    )
  rescue Date::Error
    nil
  end

  def submitted_before
    Date.new(
      attributes["submitted_before(1i)"].to_i, # year
      attributes["submitted_before(2i)"].to_i, # month
      attributes["submitted_before(3i)"].to_i, # day
    )
  rescue Date::Error
    nil
  end

  def generate_path(args)
    return index_path if args.fetch(:claims_support_claims_filter_form)
      .compact_blank.blank?

    path = index_path
    uri = URI(path)
    uri.query = args.to_query
    uri.to_s
  end

  private

  def compacted_attributes
    @compacted_attributes ||= attributes.compact_blank.except("index_path", "academic_year_id")
  end
end
