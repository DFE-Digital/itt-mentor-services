class Placements::Schools::Placements::BuildController < ApplicationController
  def new
    session[:add_a_placement] = {}
    @placement = school.placements.new(status: :draft)

    if school.primary_or_secondary_only?
      session[:add_a_placement][:placement] = @placement.attributes
      session[:add_a_placement][:phase] = school.phase
      redirect_to add_subject_placements_school_placement_build_index_path(school_id: school.id)
    else
      redirect_to add_phase_placements_school_placement_build_index_path(school_id: school.id)
    end
  end

  def add_phase
    session[:add_a_placement] = {} if session[:add_a_placement].blank?
    @placement = school.placements.new(session[:add_a_placement][:placement])
    @next_step = next_step(:add_phase)
  end

  def add_subject
    session[:add_a_placement] = {} if session[:add_a_placement].blank?
    session[:add_a_placement][:previous_step] = :add_phase
    @placement = school.placements.new(session[:add_a_placement][:placement])
    session[:add_a_placement]["subjects_attributes"].present? ? build_subject : @placement.subjects.build
    @next_step = next_step(:add_subject)
    @previous_step = previous_step(:add_subject)

    phase = school.primary_or_secondary_only? ? school.phase : session[:add_a_placement]["phase"]
    @subjects = phase == "Primary" ? Subject.primary : Subject.secondary
  end

  def add_mentors
    session[:add_a_placement] = {} if session[:add_a_placement].blank?
    session[:add_a_placement][:previous_step] = :add_subject
    @placement = school.placements.new(session[:add_a_placement][:placement])
    session[:add_a_placement]["mentors_attributes"].present? ? build_mentors : @placement.mentors.build
    @next_step = next_step(:add_subject)
    @previous_step = previous_step(:add_subject)
  end

  def check_your_answers
    @placement = school.placements.new(status: :draft)

    build_mentors
    build_subject

    session[:add_a_placement] = {} if session[:add_a_placement].blank?
    session[:add_a_placement][:previous_step] = :add_mentors
    @phase = session[:add_a_placement]["phase"]
    @next_step = next_step(:add_subject)
    @previous_step = previous_step(:add_subject)
  end

  def update
    session[:add_a_placement][:placement] = {} if session[:add_a_placement][:placement].blank?

    case params[:id].to_sym
    when :add_phase
      session[:add_a_placement][:phase] = params[:placement][:phase]
    when :add_subject
      session[:add_a_placement][:subjects_attributes] = params[:placement][:subjects_attributes]
    when :add_mentors
      session[:add_a_placement][:mentors_attributes] = params[:placement][:mentors_attributes]
    when :check_your_answers
      @placement = school.placements.new(session[:add_a_placement][:placement])
      build_mentors
      build_subject

      @placement.save!
    else
      # type code here
    end

    return redirect_to placements_school_placements_path(school) if params[:id].to_sym == :check_your_answers

    @placement = school.placements.new(placement_params) if @placement.blank?

    redirect_to public_send(next_step(params[:id]))
  end

  private

  STEPS = %i[add_phase add_subject add_mentors check_your_answers].freeze

  def next_step(step)
    index = STEPS.index(step.to_sym) + 1
    "#{STEPS[index]}_placements_school_placement_build_index_path"
  end

  def previous_step(step)
    index = STEPS.index(step) - 1
    "#{STEPS[index]}_placements_school_placement_build_index_path"
  end

  def school
    @school ||= current_user.schools.find(params.require(:school_id))
  end

  def build_mentors
    session[:add_a_placement]["mentors_attributes"]["0"]["id"].compact_blank.each do |mentor_id|
      @placement.mentors << Placements::Mentor.find(mentor_id)
    end
  end

  def build_subject
    @placement.subjects << Subject.find(session[:add_a_placement]["subjects_attributes"]["0"]["id"])
  end

  def placement_params
    params.require(:placement).permit(:subject_attributes, :mentors_attributes)
  end
end
