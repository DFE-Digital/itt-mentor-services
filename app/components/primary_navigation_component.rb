class PrimaryNavigationComponent < ApplicationComponent
  renders_many :navigation_items, "NavigationItemComponent"

  class NavigationItemComponent < ApplicationComponent
    attr_reader :name, :url, :current

    def initialize(name, url, current: false, classes: [], html_attributes: {})
      @name = name
      @url = url
      @current = current

      super(classes:, html_attributes:)
    end

    def call
      content_tag(:li, class: "app-primary-navigation__item") do
        link_to name, url, class: "app-primary-navigation__link", aria: { current: show_as_current?(url) && "page" }
      end
    end

    private

    def show_as_current?(url)
      current || current_page?(url)
    end
  end
end
