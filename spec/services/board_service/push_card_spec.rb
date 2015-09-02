require 'rails_helper'

describe 'push card' do
  let(:service) do
    BoardService.new(project_repository, board_repository)
  end
  let(:project_repository) { ProjectRepository.new }
  let(:board_repository) { BoardRepository.new }
  let(:project_service) { ProjectService.new(project_repository, board_builder) }
  let(:board_builder) { Kanban::BoardBuilder.new(board_repository) }

  let(:project_id) { project_service.launch(Project::Description.new('Name', 'Goal')) }

  before do
    project_service.specify_workflow(project_id, workflow)
  end

  context '3 state phase' do
    let(:workflow) do
      Project::Workflow.new([
        Project::PhaseSpec.new(
          Project::Phase.new('Dev'),
          Project::Transition.new([
            Project::State.new('Doing'),
            Project::State.new('Review'),
            Project::State.new('Done')
          ]),
          Project::WipLimit.new(2)
        ),
        Project::PhaseSpec.new(
          Project::Phase.new('Other'),
          Project::Transition::None.new,
          Project::WipLimit::None.new
        )
      ])
    end

    context '1 => 2' do
      it do
        feature_id = Project::FeatureId.new('feat_1')
        service.add_card(project_id, feature_id)

        from = Position('Dev', 'Doing')
        to = Position('Dev', 'Review')
        service.push_card(project_id, feature_id, from, to)

        board = board_repository.find(project_id)
        expect(board.get_card(feature_id).position).to eq(to)
      end
    end

    context '2 => 3' do
      it do
        feature_id = Project::FeatureId.new('feat_1')
        service.add_card(project_id, feature_id)
        service.push_card(project_id, feature_id, Position('Dev', 'Doing'), Position('Dev', 'Review'))

        from = Position('Dev', 'Review')
        to = Position('Dev', 'Done')
        service.push_card(project_id, feature_id, from, to)

        board = board_repository.find(project_id)
        expect(board.get_card(feature_id).position).to eq(to)
      end
    end

    context '1 => 3' do
      it do
        feature_id = Project::FeatureId.new('feat_1')
        service.add_card(project_id, feature_id)

        from = Position('Dev', 'Doing')
        to = Position('Dev', 'Done')
        expect {
          service.push_card(project_id, feature_id, from, to)
        }.to raise_error(Project::OutOfWorkflow)
      end
    end

    context '3 => next phase' do
      it do
        feature_id = Project::FeatureId.new('feat_1')
        service.add_card(project_id, feature_id)
        service.push_card(project_id, feature_id, Position('Dev', 'Doing'), Position('Dev', 'Review'))
        service.push_card(project_id, feature_id, Position('Dev', 'Review'), Position('Dev', 'Done'))

        from = Position('Dev', 'Done')
        to = Position('Other', nil)
        expect {
          service.push_card(project_id, feature_id, from, to)
        }.to raise_error(Project::OutOfWorkflow)
      end
    end
  end
end
