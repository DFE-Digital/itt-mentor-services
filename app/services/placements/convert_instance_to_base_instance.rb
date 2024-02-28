# Take an object and converts it to its base class
# This is useful when you have a STI model and you want to convert it to its base class, the primary purpose for this
# service is to assist with polymorphic_path when STI models are used as the generated paths do not map to valid routes.
# Example:
#   organisation = Placements::School.first
#   # => #<Placements::School:0x000000012d092cb0 ...>
#   Placements::ConvertInstanceToBaseInstance.call(organisation)
#   # => #<School:0x000000012d092cb0 ...>
class Placements::ConvertInstanceToBaseInstance
  include ServicePattern

  class ArgumentError < StandardError; end

  def initialize(object)
    raise ArgumentError, "Object must respond to base_class." unless object.class.respond_to?(:base_class)

    @object = object
  end

  def call
    convert_instance
  end

  private

  attr_reader :object

  def convert_instance
    object.class.base_class? ? object : object.becomes(object.class.base_class)
  end
end
