class AutocompleteSelectFormComponent < ApplicationComponent
  attr_reader :model, :scope, :url, :method, :data, :input, :hint

  # data: { :turbo, :controller, :autocomplete_path_value,
  #         :autocomplete_return_attributes_value, :input_name }
  # input: { :field_name, :value, :label, :hint, :caption, :previous_search }

  def initialize(model:, scope:, url:, method: :get, data: {},
                 input: {}, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @model = model
    @scope = scope
    @url = url
    @method = method
    @data = data
    @input = input

    setup_default_data
    validate_data
    setup_default_input_field
  end

  private

  def setup_default_data
    @data[:turbo] ||= false
    @data[:controller] ||= "autocomplete"
    @data[:input_name] ||= "#{scope}[name]"
  end

  def validate_data
    if @data[:autocomplete_path_value].blank?
      raise InvalidComponentError,
            I18n.t(
              "components.autocomplete_select_form_component.errors" \
                ".data.autocomplete_path_value.blank",
            )
    end

    if @data[:autocomplete_return_attributes_value].blank?
      raise InvalidComponentError,
            I18n.t(
              "components.autocomplete_select_form_component.errors" \
                ".data.autocomplete_return_attributes_value.blank",
            )
    end
  end

  def setup_default_input_field
    @input[:field_name] ||= :id
    @input[:label] ||= I18n.t(
      "components.autocomplete_select_form_component.label",
    )
    @input[:caption] ||= I18n.t(
      "components.autocomplete_select_form_component.caption",
    )
  end
end

class InvalidComponentError < StandardError; end
