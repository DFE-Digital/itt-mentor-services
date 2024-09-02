class ApplicationService
  private_class_method :new

  def call
    raise NoMethodError, "#call must be implemented"
  end

  def self.call(...)
    new(...).call
  end
end
