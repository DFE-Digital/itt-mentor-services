class Claims::TrainingHours
  INITIAL_TRAINING_TYPE = :initial
  REFRESHER_TRAINING_TYPE = :refresher

  HOURS_BY_PERIOD = {
    initial: {
      pre_2025: 20,
      post_2025: 16,
    },
    refresher: {
      pre_2025: 6,
      post_2025: 6,
    },
  }.freeze

  private_constant :HOURS_BY_PERIOD

  def self.for(academic_year:, training_type:)
    new(academic_year:).hours_for(training_type:)
  end

  def initialize(academic_year:)
    @academic_year = academic_year
  end

  def initial
    hours_for(training_type: INITIAL_TRAINING_TYPE)
  end

  def refresher
    hours_for(training_type: REFRESHER_TRAINING_TYPE)
  end

  def hours_for(training_type:)
    HOURS_BY_PERIOD.fetch(training_type.to_sym).fetch(period)
  end

  private

  attr_reader :academic_year

  def period
    academic_year.starts_on < Date.new(2025, 1, 1) ? :pre_2025 : :post_2025
  end
end
