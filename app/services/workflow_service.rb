class WorkflowService

  def initialize(project_repository, board_repository)
    @project_repository = project_repository
    @board_repository = board_repository
  end

  def change_wip_limit(project_id, phase, new_wip_limit)
    project = @project_repository.find(project_id)
    board = @board_repository.find(project_id)

    old = project.workflow
    new = old.change_wip_limit(phase, new_wip_limit, board)
    project.specify_workflow(new)

    @project_repository.store(project)
  end

  def disable_wip_limit(project_id, phase)
    project = @project_repository.find(project_id)

    old = project.workflow
    new = old.disable_wip_limit(phase)
    project.specify_workflow(new)

    @project_repository.store(project)
  end

  def add_phase_spec(project_id, attributes, option = nil)
    project = @project_repository.find(project_id)

    factory = Activity::WorkflowFactory.new(project.workflow)
    phase_spec_attributes = attributes.values_at(:phase, :transition, :wip_limit)

    position, base_phase = Hash(option).flatten
    case position
    when :before
      factory.insert_phase_spec_before(*phase_spec_attributes, base_phase)
    when :after
      factory.insert_phase_spec_after(*phase_spec_attributes, base_phase)
    else
      factory.add_phase_spec(*phase_spec_attributes)
    end

    project.specify_workflow(factory.build_workflow)
    @project_repository.store(project)
  end

  def set_transition(project_id, phase, transition)
    project = @project_repository.find(project_id)

    builder = Activity::WorkflowBuilder.new(project.workflow)
    builder.set_transition(phase, transition)
    project.specify_workflow(builder.workflow)

    @project_repository.store(project)
  end

  def add_state(project_id, phase, state, option)
    project = @project_repository.find(project_id)

    builder = Activity::WorkflowBuilder.new(project.workflow)
    add_with_position(option) do |position, base_state|
      case position
      when :before
        builder.insert_state_before(phase, state, base_state)
      when :after
        builder.insert_state_after(phase, state, base_state)
      end
    end

    project.specify_workflow(builder.workflow)
    @project_repository.store(project)
  end

  def remove_phase_spec(project_id, phase)
    project = @project_repository.find(project_id)
    board = @board_repository.find(project_id)

    old = project.workflow
    new = old.remove(phase, board)
    project.specify_workflow(new)

    @project_repository.store(project)
  end

  def remove_state(project_id, phase, state)
    project = @project_repository.find(project_id)
    board = @board_repository.find(project_id)

    old = project.workflow
    new = old.remove_state(phase, state, board)
    project.specify_workflow(new)

    @project_repository.store(project)
  end

  private

    def add_with_position(option)
      position, base = Hash(option).flatten
      yield(position, base)
    end
end
