module ActsAsSupportUser
  extend ActiveSupport::Concern

  included do
    def support_user?
      true
    end
  end
end
