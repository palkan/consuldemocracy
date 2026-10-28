# typed: true

# Methods of the application's classes that Sorbet can't see: methods that
# concerns expect from the classes that include them, methods defined with
# `define_method` or macros, and mixins added by macros

# Relations delegate the `acts_as_taggable_on` class methods to the model
class Budget::Investment::PrivateCollectionProxy
  include ActsAsTaggableOn::Taggable::Collection::ClassMethods
end

class User
  # `validates :terms_of_service, acceptance: true` defines this attribute at runtime
  sig { params(value: T.untyped).returns(T.untyped) }
  def terms_of_service=(value); end

  # Added by `acts_as_voter`
  include ActsAsVotable::Voter
end

# Modules added by the `acts_as_taggable_on`, `audited` and `acts_as_votable` macros;
# `pg_search_scope` (in Searchable) defines `pg_search`
class Budget::Investment
  extend ActsAsTaggableOn::Taggable::Collection::ClassMethods
  include Audited::Auditor::AuditedInstanceMethods
  include ActsAsVotable::Votable
  extend ActsAsTaggableOn::Taggable::Core::ClassMethods

  class << self
    sig { params(query: T.untyped).returns(Budget::Investment::PrivateRelation) }
    def pg_search(query); end
  end
end

module Attachable
  # `has_one_attached :attachment` and `attr_accessor :cached_attachment` in the included block
  sig { returns(ActiveStorage::Attached::One) }
  def attachment; end

  sig { params(attachable: T.untyped).returns(T.untyped) }
  def attachment=(attachable); end

  sig { returns(T.nilable(String)) }
  def cached_attachment; end

  sig { params(cached_attachment: T.nilable(String)).returns(T.nilable(String)) }
  def cached_attachment=(cached_attachment); end

  # Defined by Image and Document
  sig { returns(Symbol) }
  def association_name; end

  sig { returns(Integer) }
  def max_file_size; end

  sig { returns(T::Array[String]) }
  def accepted_content_types; end
end

module Conflictable
  sig { returns(T.nilable(Integer)) }
  def flags_count; end

  sig { returns(T.nilable(Integer)) }
  def cached_votes_up; end
end

module Flaggable
  sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
  def ignored_flag_at; end
end

module Followable
  # `has_many :followers` in the included block
  sig { returns(User::PrivateCollectionProxy) }
  def followers; end
end

module Graphqlable
  sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
  def created_at; end
end

module HasPublicAuthor
  sig { returns(T.nilable(User)) }
  def author; end
end

module Communitable
  sig { params(value: T.nilable(Integer)).returns(T.nilable(Integer)) }
  def community_id=(value); end
end

# Classes including Globalizable call `translates` before, which includes
# Globalize::ActiveRecord::InstanceMethods and extends Globalize::ActiveRecord::ClassMethods
module Globalizable
  include Globalize::ActiveRecord::InstanceMethods

  # `has_many :translations`, defined by `translates`
  sig { returns(ActiveRecord::Associations::CollectionProxy) }
  def translations; end

  # `class_attribute :translated_attribute_names`, defined by `translates`
  sig { returns(T::Array[Symbol]) }
  def translated_attribute_names; end

  # Defined by the classes that also include Searchable
  sig { returns(T::Hash[T.untyped, String]) }
  def searchable_translations_definitions; end

  module ClassMethods
    include Globalize::ActiveRecord::ClassMethods

    sig { returns(T::Array[Symbol]) }
    def translated_attribute_names; end
  end
end

module Milestoneable
  # `has_many :progress_bars` in the included block
  sig { returns(ProgressBar::PrivateCollectionProxy) }
  def progress_bars; end
end

module Notifiable
  # Defined by every class including Notifiable except Comment
  sig { returns(T.nilable(String)) }
  def title; end
end

module Relationable
  # `has_many :related_contents` in the included block
  sig { returns(RelatedContent::PrivateCollectionProxy) }
  def related_contents; end
end

module Reportable
  # `has_one :report` in the included block
  sig { params(args: T.untyped, blk: T.untyped).returns(Report) }
  def build_report(*args, &blk); end

  # Defined with `define_method` for each kind in Report::KINDS
  sig { returns(T.nilable(T::Boolean)) }
  def results_enabled?; end

  sig { returns(T.nilable(T::Boolean)) }
  def results_enabled; end

  sig { params(enabled: T.nilable(T::Boolean)).returns(T.nilable(T::Boolean)) }
  def results_enabled=(enabled); end

  sig { returns(T.nilable(T::Boolean)) }
  def stats_enabled?; end

  sig { returns(T.nilable(T::Boolean)) }
  def stats_enabled; end

  sig { params(enabled: T.nilable(T::Boolean)).returns(T.nilable(T::Boolean)) }
  def stats_enabled=(enabled); end

  sig { returns(T.nilable(T::Boolean)) }
  def advanced_stats_enabled?; end

  sig { returns(T.nilable(T::Boolean)) }
  def advanced_stats_enabled; end

  sig { params(enabled: T.nilable(T::Boolean)).returns(T.nilable(T::Boolean)) }
  def advanced_stats_enabled=(enabled); end
end

module SearchCache
  # Defined by the classes including Searchable
  sig { returns(T::Hash[T.untyped, String]) }
  def searchable_values; end
end

module Sluggable
  sig { returns(T.nilable(String)) }
  def name; end

  sig { params(value: T.nilable(String)).returns(T.nilable(String)) }
  def slug=(value); end
end

module Taggable
  # Defined by `acts_as_taggable_on :tags, :ml_tags` in the included block
  sig { returns(ActsAsTaggableOn::Tag::PrivateCollectionProxy) }
  def tags; end

  sig { returns(ActsAsTaggableOn::Tag::PrivateCollectionProxy) }
  def ml_tags; end

  sig { returns(ActsAsTaggableOn::TagList) }
  def tag_list; end

  sig { params(value: T.untyped).returns(T.untyped) }
  def tag_list=(value); end
end

module CsvExporter
  # Defined by the classes including CsvExporter
  sig { returns(T::Enumerable[T.untyped]) }
  def records; end
end

# `acts_as_votable`, `has_ancestry` and `pg_search_scope` (in Searchable)
# `has_ancestry` extends the class with Ancestry::MaterializedPath and includes Ancestry::InstanceMethods
class Comment
  include ActsAsVotable::Votable
  include Ancestry::InstanceMethods
  extend Ancestry::ClassMethods

  class << self
    sig { params(query: T.untyped).returns(Comment::PrivateRelation) }
    def pg_search(query); end
  end

  extend Ancestry::MaterializedPath
end

# `acts_as_votable`, `acts_as_taggable_on` (in Taggable) and `pg_search_scope` (in Searchable)
class Debate
  include ActsAsVotable::Votable
  extend ActsAsTaggableOn::Taggable::Core::ClassMethods

  class << self
    sig { params(query: T.untyped).returns(Debate::PrivateRelation) }
    def pg_search(query); end
  end
end

module Statisticable
  # Defined by the classes including Statisticable
  sig { returns(T.any(T::Array[Integer], ActiveRecord::Relation)) }
  def participant_ids; end

  sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
  def participation_date; end

  sig { returns(Integer) }
  def total_participants; end

  sig { params(key: T.any(String, Symbol)).returns(String) }
  def full_cache_key_for(key); end
end

module SDG::Relatable
  # Associations declared in the included block
  sig { returns(SDG::Relation::PrivateCollectionProxy) }
  def sdg_relations; end

  sig { returns(ActiveRecord::Associations::CollectionProxy) }
  def sdg_goals; end

  sig { params(value: T::Enumerable[T.untyped]).void }
  def sdg_goals=(value); end

  sig { returns(ActiveRecord::Associations::CollectionProxy) }
  def sdg_global_targets; end

  sig { params(value: T::Enumerable[T.untyped]).void }
  def sdg_global_targets=(value); end

  sig { returns(ActiveRecord::Associations::CollectionProxy) }
  def sdg_local_targets; end

  sig { params(value: T::Enumerable[T.untyped]).void }
  def sdg_local_targets=(value); end
end

module SDG::Related
  # `has_many :relations` in the included block
  sig { returns(SDG::Relation::PrivateCollectionProxy) }
  def relations; end

  # Defined by SDG::Goal, SDG::Target and SDG::LocalTarget
  sig { returns(T.nilable(T.any(Integer, String))) }
  def code; end

  sig { returns(T.nilable(String)) }
  def title; end
end

# `translates :value`
class I18nContent
  include Globalize::ActiveRecord::InstanceMethods
  extend Globalize::ActiveRecord::ClassMethods

  class << self
    sig { returns(T::Array[Symbol]) }
    def translated_attribute_names; end
  end
end

# `acts_as_votable` includes ActsAsVotable::Votable, `acts_as_taggable_on` extends the
# taggable class methods and `pg_search_scope` (in Searchable) defines `pg_search`
class Proposal
  include ActsAsVotable::Votable
  extend ActsAsTaggableOn::Taggable::Core::ClassMethods

  class << self
    sig { params(query: T.untyped).returns(Proposal::PrivateRelation) }
    def pg_search(query); end
  end
end

# `pg_search_scope` (in Searchable) defines `pg_search`
class ProposalNotification
  class << self
    sig { params(query: T.untyped).returns(ProposalNotification::PrivateRelation) }
    def pg_search(query); end
  end
end

# `pg_search_scope` (in Searchable) defines `pg_search`
class Poll
  class << self
    sig { params(query: T.untyped).returns(Poll::PrivateRelation) }
    def pg_search(query); end
  end
end

# Methods that `translation_class_delegate :budget` (Globalizable) defines on translation classes.
class Budget::Group::Translation
  sig { returns(T.nilable(Budget)) }
  def budget; end
end

class Budget::Heading::Translation
  sig { returns(T.nilable(Budget)) }
  def budget; end
end

# Defined at runtime by `define_singleton_method` for every kind in Budget::Phase::PHASE_KINDS
class Budget::Phase
  class << self
    sig { returns(T.nilable(Budget::Phase)) }
    def informing; end

    sig { returns(T.nilable(Budget::Phase)) }
    def accepting; end

    sig { returns(T.nilable(Budget::Phase)) }
    def reviewing; end

    sig { returns(T.nilable(Budget::Phase)) }
    def selecting; end

    sig { returns(T.nilable(Budget::Phase)) }
    def valuating; end

    sig { returns(T.nilable(Budget::Phase)) }
    def publishing_prices; end

    sig { returns(T.nilable(Budget::Phase)) }
    def balloting; end

    sig { returns(T.nilable(Budget::Phase)) }
    def reviewing_ballots; end

    sig { returns(T.nilable(Budget::Phase)) }
    def finished; end
  end

  module GeneratedAssociationRelationMethods
    sig { returns(T.nilable(Budget::Phase)) }
    def informing; end

    sig { returns(T.nilable(Budget::Phase)) }
    def accepting; end

    sig { returns(T.nilable(Budget::Phase)) }
    def reviewing; end

    sig { returns(T.nilable(Budget::Phase)) }
    def selecting; end

    sig { returns(T.nilable(Budget::Phase)) }
    def valuating; end

    sig { returns(T.nilable(Budget::Phase)) }
    def publishing_prices; end

    sig { returns(T.nilable(Budget::Phase)) }
    def balloting; end

    sig { returns(T.nilable(Budget::Phase)) }
    def reviewing_ballots; end

    sig { returns(T.nilable(Budget::Phase)) }
    def finished; end
  end
end

# Defined with `define_method` for every channel (Poll::Voter::VALID_ORIGINS) and vote type
class Poll::Stats
  sig { returns(Integer) }
  def total_participants_web; end

  sig { returns(Float) }
  def total_participants_web_percentage; end

  sig { returns(Integer) }
  def total_participants_booth; end

  sig { returns(Float) }
  def total_participants_booth_percentage; end

  sig { returns(Integer) }
  def total_participants_letter; end

  sig { returns(Float) }
  def total_participants_letter_percentage; end

  sig { returns(Float) }
  def valid_percentage_web; end

  sig { returns(Float) }
  def valid_percentage_booth; end

  sig { returns(Float) }
  def valid_percentage_letter; end

  sig { returns(Integer) }
  def total_valid_votes; end

  sig { returns(Float) }
  def total_valid_percentage; end

  sig { returns(Float) }
  def white_percentage_web; end

  sig { returns(Float) }
  def white_percentage_booth; end

  sig { returns(Float) }
  def white_percentage_letter; end

  sig { returns(Integer) }
  def total_white_votes; end

  sig { returns(Float) }
  def total_white_percentage; end

  sig { returns(Float) }
  def null_percentage_web; end

  sig { returns(Float) }
  def null_percentage_booth; end

  sig { returns(Float) }
  def null_percentage_letter; end

  sig { returns(Integer) }
  def total_null_votes; end

  sig { returns(Float) }
  def total_null_percentage; end
end

# `globalize_accessors` (in Globalizable) includes Globalize::Accessors::InstanceMethods
class Poll::Question
  include Globalize::Accessors::InstanceMethods
end

# `pg_search_scope` (in Searchable) defines `pg_search`
class Legislation::Process
  class << self
    sig { params(query: T.untyped).returns(Legislation::Process::PrivateRelation) }
    def pg_search(query); end
  end
end

class Legislation::Proposal
  include ActsAsVotable::Votable

  class << self
    sig { params(query: T.untyped).returns(Legislation::Proposal::PrivateRelation) }
    def pg_search(query); end
  end
end

# Scope defined by `has_ancestry`
class Comment::PrivateRelation
  sig { returns(Comment::PrivateRelation) }
  def roots; end
end

class Comment::PrivateAssociationRelation
  sig { returns(Comment::PrivateAssociationRelation) }
  def roots; end
end

class Comment::PrivateCollectionProxy
  sig { returns(Comment::PrivateAssociationRelation) }
  def roots; end
end

# GlobalizeHelper is also included in components, so it can't require SiteCustomizationHelper.
# In views (the only place where this method is called) it comes from SiteCustomizationHelper.
module GlobalizeHelper
  sig { params(locale: T.any(String, Symbol)).returns(T::Boolean) }
  def site_customization_enable_translation?(locale); end
end

# Every model that includes ActsAsParanoidAliases calls `acts_as_paranoid` first, which
# includes Paranoia and extends Paranoia::Query
module ActsAsParanoidAliases
  include Paranoia
end

module ActsAsParanoidAliases::ClassMethods
  include Paranoia::Query
end
