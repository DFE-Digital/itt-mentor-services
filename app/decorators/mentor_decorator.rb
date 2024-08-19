class MentorDecorator < Draper::Decorator
  delegate_all

  def mentor_school_placements(school)
    placements.where(school:).decorate
  end
end
