# typed: strict
class TagCloud
  extend T::Sig

  ResourceModel = T.type_alias do
    T.any(T.class_of(Proposal), T.class_of(Debate), T.class_of(Budget::Investment))
  end

  sig { returns(ResourceModel) }
  attr_accessor :resource_model

  sig { returns(T.nilable(String)) }
  attr_accessor :scope

  sig { params(resource_model: ResourceModel, scope: T.nilable(String)).void }
  def initialize(resource_model, scope = nil)
    @resource_model = resource_model
    @scope = scope
  end

  sig { returns(ActsAsTaggableOn::Tag::PrivateRelation) }
  def tags
    resource_model_scoped
      .last_week.send(counts)
      .where("lower(name) NOT IN (?)", category_names + geozone_names + default_blacklist)
      .order("#{table_name}_count": :desc, name: :asc)
      .limit(10)
  end

  sig { returns(Symbol) }
  def counts
    if Tag.machine_learning? && [Proposal, Budget::Investment].include?(resource_model)
      :ml_tag_counts
    else
      :tag_counts
    end
  end

  sig { returns(T::Array[String]) }
  def category_names
    Tag.category_names.map(&:downcase)
  end

  sig { returns(T::Array[String]) }
  def geozone_names
    Geozone.all.map { |geozone| T.must(geozone.name).downcase }
  end

  sig do
    returns(T.any(ResourceModel, Proposal::PrivateRelation, Proposal::PrivateAssociationRelation))
  end
  def resource_model_scoped
    scope = self.scope
    scope && resource_model == Proposal ? Proposal.search(scope) : resource_model
  end

  sig { returns(T::Array[String]) }
  def default_blacklist
    [""]
  end

  sig { returns(String) }
  def table_name
    resource_model.to_s.tableize.tr("/", "_")
  end
end
