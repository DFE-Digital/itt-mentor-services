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
    elsif context.to_s.include?("placements")
      "Manage school placements"
    end
  end

  private

  attr_reader :context, :current_user, :organisation, :current_navigation

  delegate :current_page?, :t, to: :view_context

  def navigation_items
    case context
    when :claims_support
      claims_support_navigation
    when :claims_school
      claims_school_navigation
    when :placements_school
      placements_school_navigation
    when :placements_provider
      placements_provider_navigation
    else
      []
    end
  end

  def current?(key)
    key.to_sym == current_navigation
  end

  # Navigation definitions

  def claims_support_navigation
    [
      { text: t(".organisations"), href: view_context.claims_support_schools_path, current: current?(:organisations) },
      { text: t(".claims"), href: view_context.claims_support_claims_path, current: current?(:claims) },
      { text: t(".support_users"), href: view_context.claims_support_support_users_path, current: current?(:users) },
      { text: t(".settings"), href: view_context.claims_support_settings_path, current: current?(:settings) },
    ]
  end

  def claims_school_navigation
    return [] unless organisation

    [
      { text: t(".claims"), href: view_context.claims_school_claims_path(organisation), current: current?(:claims) },
      { text: t(".mentors"), href: view_context.claims_school_mentors_path(organisation), current: current?(:mentors) },
      { text: t(".users"), href: view_context.claims_school_users_path(organisation), current: current?(:users) },
      { text: t(".details"), href: view_context.claims_school_path(organisation), current: current?(:details) },
    ]
  end

  def placements_school_navigation
    return [] unless organisation

    items = []

    items << if organisation.expression_of_interest_completed?
               {
                 text: t(".placements"),
                 href: view_context.placements_school_placements_path(organisation),
                 current: current?(:placements),
               }
             else
               {
                 text: t(".placements"),
                 href: view_context.new_add_hosting_interest_placements_school_hosting_interests_path(organisation),
                 current: current?(:placements),
               }
             end

    items << {
      text: t(".mentors"),
      href: view_context.placements_school_mentors_path(organisation),
      current: current?(:mentors),
    }

    if Flipper.enabled?(:school_partner_providers, organisation)
      items << {
        text: t(".providers"),
        href: view_context.placements_school_partner_providers_path(organisation),
        current: current?(:partner_providers),
      }
    end

    items << {
      text: t(".users"),
      href: view_context.placements_school_users_path(organisation),
      current: current?(:users),
    }

    items << {
      text: t(".organisation_details"),
      href: view_context.placements_school_path(organisation),
      current: current?(:organisation_details),
    }

    items
  end

  def placements_provider_navigation
    return [] unless organisation

    items = []

    unless Flipper.enabled?(:provider_hide_find_placements, organisation)
      items << {
        text: t(".find"),
        href: view_context.placements_provider_find_index_path(organisation),
        current: current?(:find),
      }
    end

    items += [
      {
        text: t(".placements"),
        href: view_context.placements_provider_placements_path(organisation),
        current: current?(:placements),
      },
      {
        text: t(".schools"),
        href: view_context.placements_provider_partner_schools_path(organisation),
        current: current?(:partner_schools),
      },
      {
        text: t(".users"),
        href: view_context.placements_provider_users_path(organisation),
        current: current?(:users),
      },
      {
        text: t(".organisation_details"),
        href: view_context.placements_provider_path(organisation),
        current: current?(:organisation_details),
      },
    ]

    items
  end
end
