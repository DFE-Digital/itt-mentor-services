class ClaimWindowNavigationComponent < ApplicationComponent
  renders_many :navigation_items, "NavigationItemComponent"

  class NavigationItemComponent < ApplicationComponent
    def initialize(name, url, current: false, classes: [], html_attributes: {})
      @name = name
      @url = url
      @current = current

      super(classes:, html_attributes:)
    end

    def call
      content_tag(:li, class: "app-secondary-navigation__item") do
        link_to name, url, class: "app-secondary-navigation__link", aria: { current: current? && "page" }
      end
    end

    private

    attr_reader :name, :url, :current

    def current?
      if params[:academic_year_id].present?
        name.include?(selected_academic_year.name)
      else
        name.include?(current_academic_year.name)
      end
    end

    def selected_academic_year
      @selected_academic_year = AcademicYear.find(params[:academic_year_id])
    end

    def current_academic_year
      @current_academic_year ||= AcademicYear.for_date(Date.current)
    end
  end
end
