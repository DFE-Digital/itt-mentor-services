class Placements::BaseStep
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_reader :wizard

  def initialize(wizard:, attributes:)
    @wizard = wizard
    super(attributes)
  end

  def to_partial_path
    "#{base_path}#{class_to_path(self.class)}"
  end

  private

  def base_path
    "placements/wizards/#{class_to_path(wizard.class)}/"
  end

  def class_to_path(klass)
    klass.name.demodulize.underscore
  end
end
