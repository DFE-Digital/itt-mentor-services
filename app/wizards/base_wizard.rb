class BaseWizard
  attr_reader :state, :params, :current_step, :steps

  def self.generate_state_key
    SecureRandom.uuid
  end

  def initialize(state:, params:, current_step: nil)
    @state = state
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

  def add_step(step_class, preset_attributes = {}, step_identifier = nil)
    name = step_name(step_class, preset_attributes[step_identifier])
    attributes = step_attributes(name, step_class, preset_attributes)
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

  def step_name(step_class, id = nil)
    # e.g. YearGroupStep becomes :year_group
    name = step_class.name.chomp("Step").demodulize.underscore
    return name.to_sym if id.blank?

    "#{name}_#{id}".to_sym
  end

  def step_attributes(name, step_class, preset_attributes = {})
    state_key = name.to_s

    attributes = if name == current_step
                   # Try and populate from the params, then fall back to the session
                   params_key = step_class.model_name.param_key
                   params[params_key]&.permit! || state[state_key]
                 else
                   state[state_key]
                 end

    return attributes if preset_attributes.blank?

    attributes = {} if attributes.blank?
    attributes.merge(preset_attributes)
  end
end
