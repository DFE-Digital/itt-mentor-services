module DemodulizesPolicyClass
  extend ActiveSupport::Concern

  class_methods do
    def policy_class
      "#{name.demodulize}Policy"
    end
  end
end
