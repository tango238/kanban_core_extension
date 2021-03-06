require 'rails_helper'

module Project
  describe 'load Project domain object' do
    before do
      project_record = ::Project::Project.new(
        project_id: project_id,
        description_name: 'name',
        description_goal: 'goal'
      )
      project_record.phase_spec_records.build(
        order: 1,
        phase_name: 'Todo',
        wip_limit_count: nil
      )
      project_record.phase_spec_records.build(
        order: 2,
        phase_name: 'Dev',
        wip_limit_count: 2
      )
      project_record.state_records.build(
        order: 1,
        phase_name: 'Dev',
        state_name: 'Doing'
      )
      project_record.state_records.build(
        order: 2,
        phase_name: 'Dev',
        state_name: 'Done'
      )
      project_record.phase_spec_records.build(
        order: 3,
        phase_name: 'QA',
        wip_limit_count: 1
      )
      project_record.save!
    end

    let(:project) { ::Project::Project.last }
    let(:project_id) { ProjectId.new('prj_123') }

    describe 'ProjectId' do
      subject { project.project_id }
      it { is_expected.to eq(project_id) }
    end

    describe 'Description' do
      subject { project.description }
      it { is_expected.to eq(Description.new('name', 'goal')) }
    end

    describe 'Workflow#1' do
      subject { project.workflow.to_a[0] }
      it do
        is_expected.to eq(
          Activity::PhaseSpec.new(
            Activity::Phase.new('Todo'),
            Activity::NoTransition.new,
            Activity::NoWipLimit.new
          )
        )
      end
    end

    describe 'Workflow#2' do
      subject { project.workflow.to_a[1] }
      it do
        is_expected.to eq(
          Activity::PhaseSpec.new(
            Activity::Phase.new('Dev'),
            Activity::Transition.new([
              Activity::State.new('Doing'),
              Activity::State.new('Done'),
            ]),
            Activity::WipLimit.new(2)
          )
        )
      end
    end

    describe 'Workflow#3' do
      subject { project.workflow.to_a[2] }
      it do
        is_expected.to eq(
          Activity::PhaseSpec.new(
            Activity::Phase.new('QA'),
            Activity::NoTransition.new,
            Activity::WipLimit.new(1)
          )
        )
      end
    end
  end
end
