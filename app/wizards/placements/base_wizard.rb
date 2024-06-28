class Placements::BaseWizard
  attr_reader :state, :params, :current_step, :steps

  def initialize(session:, params:, current_step: nil)
    @state = session[self.class.name] ||= {}
    @params = params

    # Initialise steps
    @current_step = current_step
    @steps = {}
    define_steps
    @current_step ||= first_step
    raise "The step \"#{@current_step}\" does not exist" unless steps.key?(@current_step)
  end

  def define_steps
    # Define the wizard steps here
    # add_step(FirstStep)
    # add_step(SecondStep) if step[:first].some_attribute == "some_value"
    # add_step(FinalStep)
  end

  def add_step(step_class)
    name = step_name(step_class)
    attributes = step_attributes(name, step_class)
    @steps[name] = step_class.new(wizard: self, attributes:)
  end

  def step
    steps[current_step]
  end

  def save_step
    if step.valid?
      state[current_step.to_s] = step.attributes
      true
    else
      false
    end
  end

  def reset_state
    state.clear
  end

  def valid?
    steps.values.all?(&:valid?)
  end

  def first_step
    steps.keys.first
  end

  def next_step
    all_steps = steps.keys
    current_index = all_steps.index(current_step)
    all_steps[current_index + 1] || false
  end

  def previous_step
    all_steps = steps.keys
    current_index = all_steps.index(current_step)
    current_index.positive? ? all_steps[current_index - 1] : false
  end

  private

  def step_name(step_class)
    # e.g. YearGroupStep becomes :year_group
    step_class.name.chomp("Step").demodulize.underscore.to_sym
  end

  def step_attributes(name, step_class)
    state_key = name.to_s

    if name == current_step
      # Try and populate from the params, then fall back to the session
      params_key = step_class.model_name.param_key
      params[params_key]&.permit! || state[state_key]
    else
      state[state_key]
    end
  end
end
