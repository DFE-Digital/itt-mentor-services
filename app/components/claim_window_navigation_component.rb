class ClaimWindowNavigationComponent < ApplicationComponent
  renders_many :navigation_items, "NavigationItemComponent"

  class NavigationItemComponent < ApplicationComponent
    attr_reader :academic_year, :url, :current

    def initialize(academic_year:, url:, current:, classes: [], html_attributes: {})
      @academic_year = academic_year
      @url = url
      @current = current

      super(classes:, html_attributes:)
    end

    def call
      content_tag(:li, class: "app-secondary-navigation__item") do
        link_to academic_year.card_name, url, class: "app-secondary-navigation__link", aria: { current: current && "page" }
      end
    end
  end
end
