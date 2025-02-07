class Claims::SupportDetailsWizard::SupportUserStep < BaseStep
  attribute :support_user_id

  validates :support_user_id, presence: true, inclusion: { in: ->(step) { step.support_users.ids } }

  def support_users
    Claims::SupportUser.all
  end
end
