class PrimaryNavigationComponent < ApplicationComponent
  def initialize(context:, current_user:, organisation: nil, current_navigation: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)
    @context = context.to_sym
    @current_user = current_user
    @organisation = organisation
    @current_navigation = current_navigation
  end

  def service_name
    if context.to_s.include?("claims")
      "Claim funding for mentor training"
    else
      "Manage school placements"
    end
  end

  private

  attr_reader :context, :current_user, :organisation, :current_navigation

  delegate :current_page?, :t, to: :view_context

  def navigation_items
    case context
    when :claims_support then claims_support_navigation_items
    when :claims_school then claims_school_navigation_items
    when :placements_school then placements_school_navigation_items
    else
      placements_provider_navigation_items
    end
  end

  def provider_find_navigation_item
    return nil if feature_enabled?(:provider_hide_find_placements)

    build_item(:find, href: placements_provider_find_index_path(organisation), key: :find)
  end

  def claims_support_navigation_items
    build_navigation_items([
      [:organisations, claims_support_schools_path, :organisations],
      [:claims, claims_support_claims_path, :claims],
      [:support_users, claims_support_support_users_path, :users],
      [:settings, claims_support_settings_path, :settings],
    ])
  end

  def claims_school_navigation_items
    build_navigation_items([
      [:claims, claims_school_claims_path(organisation), :claims],
      [:mentors, claims_school_mentors_path(organisation), :mentors],
      [:users, claims_school_users_path(organisation), :users],
      [:details, claims_school_path(organisation), :details],
    ])
  end

  def placements_school_navigation_items
    [
      build_item(:placements, href: placements_school_placements_path_for_org, key: :placements),
      build_item(:mentors, href: placements_school_mentors_path(organisation), key: :mentors),
      partner_providers_navigation_item,
      build_item(:users, href: placements_school_users_path(organisation), key: :users),
      build_item(:organisation_details, href: placements_school_path(organisation), key: :organisation_details),
    ].compact
  end

  def placements_provider_navigation_items
    [
      provider_find_navigation_item,
      build_item(:placements, href: placements_provider_placements_path(organisation), key: :placements),
      build_item(:schools, href: placements_provider_partner_schools_path(organisation), key: :partner_schools),
      build_item(:users, href: placements_provider_users_path(organisation), key: :users),
      build_item(:organisation_details, href: placements_provider_path(organisation), key: :organisation_details),
    ].compact
  end

  def current?(key)
    key.to_sym == current_navigation
  end

  def build_item(text_key, href:, key:)
    { text: t(".#{text_key}"), href:, current: current?(key) }
  end

  def build_navigation_items(defs)
    defs.map { |text_key, href, key| build_item(text_key, href:, key:) }
  end

  def partner_providers_navigation_item
    if feature_enabled?(:school_partner_providers)
      build_item(:providers, href: placements_school_partner_providers_path(organisation), key: :partner_providers)
    end
  end

  def placements_school_placements_path_for_org
    if organisation.expression_of_interest_completed?
      placements_school_placements_path(organisation)
    else
      new_add_hosting_interest_placements_school_hosting_interests_path(organisation)
    end
  end

  def feature_enabled?(flag)
    Flipper.enabled?(flag, organisation)
  end
end
