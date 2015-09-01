class BoardService

  def initialize(project_repository, board_repository)
    @project_repository = project_repository
    @board_repository = board_repository
  end

  def add_card(project_id, feature_id)
    project = @project_repository.find(project_id)
    board = @board_repository.find(project_id)

    rule = Kanban::Rule.new(project.workflow)
    board.add_card(feature_id, rule)

    @board_repository.store(board)
  end

  def pull_card(project_id, feature_id, before, after)
    project = @project_repository.find(project_id)
    board = @board_repository.find(project_id)

    rule = Kanban::Rule.new(project.workflow)
    board.pull_card(feature_id, before, after, rule)

    @board_repository.store(board)
  end

  def push_card(project_id, feature_id, before, after)
    project = @project_repository.find(project_id)
    board = @board_repository.find(project_id)

    rule = Kanban::Rule.new(project.workflow)
    board.push_card(feature_id, before, after, rule)

    @board_repository.store(board)
  end
end
