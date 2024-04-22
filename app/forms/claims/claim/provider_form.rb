class Claims::Claim::ProviderForm < ApplicationForm
  attr_accessor :id, :provider_id, :school, :current_user

  validates :provider_id, presence: true

  def initialize(attributes = {})
    super

    self.provider_id ||= claim.provider_id
  end

  def persist
    claim.provider_id = provider_id
    claim.status = :internal_draft if claim.status.nil?
    claim.created_by = current_user

    ActiveRecord::Base.transaction do
      claim.save!
      claim.mentor_trainings.each do |mentor_training|
        mentor_training.update!(provider_id:)
      end
    end
  end

  def claim
    @claim ||= school.claims.find_or_initialize_by(id:)
  end
end
