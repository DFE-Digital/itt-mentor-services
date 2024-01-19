module ActsAsSupportUser
  extend ActiveSupport::Concern

  SUPPORT_EMAIL_REGEXP = /\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@education.gov.uk\z/

  included do
    validates :email, presence: true, format: { with: SUPPORT_EMAIL_REGEXP, message: :invalid_support_email }

    def support_user?
      true
    end
  end
end
