class SetTransitionCommand
  include ActiveModel::Model

  attr_accessor :project_id_str, :phase_name, :state_names

  validates :project_id_str, presence: true
  validates :phase_name, presence: true
  validates :state_names, transition: true

  def project_id
    Project::ProjectId.new(project_id_str)
  end

  def phase
    Project::Phase.new(phase_name)
  end

  def transition
    Project::Transition.from_array(state_names)
  end

  def execute(service)
    return false unless valid?
    service.set_transition(project_id, phase, transition)
  end
end