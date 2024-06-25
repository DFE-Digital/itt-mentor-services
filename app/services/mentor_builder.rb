class MentorBuilder
  include ServicePattern

  def initialize(trn:, date_of_birth:, first_name: nil, last_name: nil, mentor_klass: Placements::Mentor)
    @trn = trn
    @first_name = first_name
    @last_name = last_name
    @date_of_birth = date_of_birth
    @mentor_klass = mentor_klass
  end

  def call
    mentor = Mentor.find_or_initialize_by(trn:).becomes(mentor_klass)
    return mentor if mentor.invalid_attributes?(:trn)
    return mentor if date_of_birth.nil?

    mentor.assign_attributes(
      first_name: teacher["firstName"],
      last_name: teacher["lastName"],
    )
    mentor
  end

  private

  attr_accessor :trn, :first_name, :last_name, :date_of_birth, :mentor_klass

  def teacher
    @teacher ||= TeachingRecord::GetTeacher.call(trn:, date_of_birth: date_of_birth.to_s)
  end
end
