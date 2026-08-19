class Claims::Providers::Claims::FilterFormComponent < ApplicationComponent
  def initialize(
    filter_form:,
    schools:,
    school_search_endpoint:,
    school_search_fieldname:,
    school_search_labelname:,
    classes: [],
    html_attributes: {}
  )
    super(classes:, html_attributes:)

    @filter_form = filter_form
    @schools = schools
    @school_search_endpoint = school_search_endpoint
    @school_search_fieldname = school_search_fieldname
    @school_search_labelname = school_search_labelname
  end

  private

  attr_reader :filter_form, :schools, :school_search_endpoint, :school_search_fieldname, :school_search_labelname
end
