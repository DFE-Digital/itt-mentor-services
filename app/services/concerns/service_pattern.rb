module ServicePattern
  def self.included(base)
    base.extend ClassMethods
    base.class_eval { private_class_method :new }
  end

  def call
    raise NoMethodError, "#call must be implemented"
  end

  module ClassMethods
    def call(...)
      new(...).call
    end
  end
end
