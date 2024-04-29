class Claims::MentorBuilder
  include ServicePattern

  def initialize(trn:, first_name: nil, last_name: nil, date_of_birth: nil)
    @trn = trn
    @first_name = first_name
    @last_name = last_name
    @date_of_birth = date_of_birth
  end

  def call
    mentor = Mentor.find_or_initialize_by(trn:).becomes(Claims::Mentor)
    return mentor if mentor.invalid_attributes?(:trn) # Return mentor if basic validation fails
    return mentor if date_of_birth.nil?

    mentor.assign_attributes(
      first_name: teacher["firstName"],
      last_name: teacher["lastName"],
    )
    mentor
  end

  private

  attr_accessor :trn, :first_name, :last_name, :date_of_birth

  def teacher
    @teacher ||= TeachingRecord::GetTeacher.call(trn:, date_of_birth: date_of_birth.to_s)
  end
end
