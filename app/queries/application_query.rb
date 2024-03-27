class ApplicationQuery
  attr_reader :params

  def initialize(params: {})
    @params = params
  end

  def self.call(...)
    new(...).call
  end
end
