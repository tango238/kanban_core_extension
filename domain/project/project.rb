module Project
  class Project < ActiveRecord::Base
    include Arize::Project

    def specify_workflow(a_workflow)
      self.workflow = a_workflow
    end

    def add_phase_spec(phase_spec)
      specify_workflow(workflow.add(phase_spec))
    end

    def change_wip_limit(phase, new_wip_limit, board)
      old_phase_spec = workflow.spec(phase)
      new_phase_spec = old_phase_spec.change_wip_limit(new_wip_limit, board)
      new_workflow = workflow.replace_with(old_phase_spec, new_phase_spec)
      specify_workflow(new_workflow)
    end
  end
end
