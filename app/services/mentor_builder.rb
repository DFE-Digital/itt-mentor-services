class MentorBuilder
  include ServicePattern

  def initialize(trn:, first_name: nil, last_name: nil)
    @trn = trn
    @first_name = first_name
    @last_name = last_name
  end

  def call
    mentor = Mentor.find_or_initialize_by(trn:)
    return mentor if mentor.persisted? # We already have the data (first_name, last_name), so don't need to fetch or assign
    return mentor if mentor.invalid_attributes?(:trn) # If the trn doesn't meet basic validation, we can't build any further

    mentor.assign_attributes(first_name: first_name || teacher["firstName"],
                             last_name: last_name || teacher["lastName"])
    mentor
  end

  private

  attr_accessor :trn, :first_name, :last_name

  def teacher
    @teacher ||= TeachingRecord::GetTeacher.call(trn:)
  end
end
