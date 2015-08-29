module GroupCreator

  def Group(spec)
    Work::Group.new(
      spec[:project_id],
      Phase(spec[:phase]),
      WipLimit(spec[:wip_limit]),
      Transition(spec[:transition]),
      WorkList(spec[:work_list])
    )
  end

  def Phase(spec)
    Work::Phase.new(spec)
  end

  def WipLimit(spec)
    if spec
      Work::WipLimit.new(spec)
    else
      Work::WipLimit::None.new
    end
  end

  def Transition(spec)
    if spec
      Work::Transition.new(spec.map {|e| State(e) })
    else
      Work::EmptyTransition.new
    end
  end

  def WorkList(spec)
    Work::WorkList.new(spec)
  end

  def Work(feature_id, state)
    Work::Work.new(feature_id, state)
  end

  def FeatureId(spec)
    Feature::FeatureId.new(spec)
  end

  def State(spec)
    if spec
      Work::State.new(spec)
    else
      Work::State::None.new
    end
  end
end