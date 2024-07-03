class Placements::BaseStep
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_reader :wizard

  def initialize(wizard:, attributes:)
    @wizard = wizard
    super(attributes)
  end

  def to_partial_path
    wizard_name = class_to_path(wizard.class)
    step_name = class_to_path(self.class)
    "placements/wizards/#{wizard_name}/#{step_name}"
  end

  private

  def class_to_path(klass)
    klass.name.demodulize.underscore
  end
end
