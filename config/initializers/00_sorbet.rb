# Sorbet signatures are checked at runtime in development and test, so wrong
# signatures make the test suite fail. In production, signatures aren't checked.
T::Configuration.default_checked_level = :never unless Rails.env.local?

# Tapioca declares `Model::PrivateRelation`, `Model::PrivateAssociationRelation`
# and `Model::PrivateCollectionProxy` for every model (see sorbet/rbi/dsl/).
# These constants don't exist at runtime, so we alias them to the relation
# classes Rails generates. This way, signatures can use them.
module SorbetRelationConstants
  RELATION_CLASSES = {
    PrivateRelation: :ActiveRecord_Relation,
    PrivateAssociationRelation: :ActiveRecord_AssociationRelation,
    PrivateCollectionProxy: :ActiveRecord_Associations_CollectionProxy
  }.freeze

  def self.define(model)
    RELATION_CLASSES.each do |alias_name, name|
      next if model.const_defined?(alias_name, false) || !model.const_defined?(name, false)

      model.const_set(alias_name, model.const_get(name, false))
    end
  end

  def inherited(subclass)
    super
    SorbetRelationConstants.define(subclass)
  end
end

ActiveSupport.on_load(:active_record) do
  singleton_class.prepend(SorbetRelationConstants)
  descendants.each { |model| SorbetRelationConstants.define(model) }
end
