class Claims::AddSchoolWizard::ClaimWindowStep < BaseStep
  attribute :claim_window_id

  validates :claim_window_id, presence: true, inclusion: { in: ->(step) { step.valid_claim_window_ids } }

  def claim_windows_for_selection
    option = Struct.new(:id, :name, :phase_of_time)

    options = []
    if current_claim_window.present?
      options << option.new(
        id: current_claim_window.id,
        name: current_claim_window.name,
        phase_of_time: "Current",
      )
    end
    if upcoming_claim_window.present?
      options << option.new(
        id: upcoming_claim_window.id,
        name: upcoming_claim_window.name,
        phase_of_time: "Upcoming",
      )
    end
    options
  end

  def valid_claim_window_ids
    [current_claim_window&.id, upcoming_claim_window&.id].compact.flatten
  end

  private

  def current_claim_window
    @current_claim_window = Claims::ClaimWindow.current&.decorate
  end

  def upcoming_claim_window
    @upcoming_claim_window = Claims::ClaimWindow.next&.decorate
  end
end
