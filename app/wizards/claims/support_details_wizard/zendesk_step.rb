class Claims::SupportDetailsWizard::ZendeskStep < BaseStep
  attribute :zendesk_url

  validates :zendesk_url, presence: true
end
