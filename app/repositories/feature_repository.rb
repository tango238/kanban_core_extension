class AssignFeatureNumberError < StandardError; end

class FeatureRepository

  def find(project_id, feature_id)
    ::Feature::Feature.find_by(
      project_id: project_id,
      feature_id: feature_id
    )
  end

  def store(feature)
    return feature.save! if feature.persisted?
    raise AssignFeatureNumberError unless feature.number == next_number(feature.project_id)
    feature.save!
  end

  def next_number(project_id)
    last_number(project_id) + 1
  end

  private

    def last_number(project_id)
      return 0 unless r = last_record(project_id)
      r.number
    end

    def last_record(project_id)
      ::Feature::Feature
        .where(project_id: project_id)
        .order(id: :desc)
        .first
    end
end
