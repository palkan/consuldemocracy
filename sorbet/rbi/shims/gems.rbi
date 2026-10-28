# typed: true

# Methods that gems add at runtime and that the gem RBIs don't declare

# Defined in config/initializers/globalize.rb
module Globalize
  class << self
    sig { returns(T.untyped) }
    def set_fallbacks_to_all_available_locales; end
  end
end

# Defined in config/initializers/vote_extensions.rb
class ActsAsVotable::Vote
  class << self
    sig { params(votable_type: String).returns(Integer) }
    def count_for(votable_type); end
  end
end

# Alias of `voted_on?` defined in ActsAsVotable::Voter.included
module ActsAsVotable::Voter
  sig { params(votable: T.untyped, args: T::Hash[Symbol, T.untyped]).returns(T::Boolean) }
  def voted_for?(votable, args = {}); end
end

# Defined in config/initializers/acts_as_taggable_on.rb
class ActsAsTaggableOn::Tag
  sig { returns(T::Boolean) }
  def category?; end

  sig { params(taggable_type: String).returns(Integer) }
  def increment_custom_counter_for(taggable_type); end

  sig { params(taggable_type: String).returns(Integer) }
  def decrement_custom_counter_for(taggable_type); end

  class << self
    sig { returns(T::Array[String]) }
    def category_names; end

    sig { params(term: T.nilable(String)).returns(ActsAsTaggableOn::Tag::PrivateRelation) }
    def search(term); end

    sig { params(term: T.nilable(String)).returns(ActsAsTaggableOn::Tag::PrivateRelation) }
    def pg_search(term); end
  end
end

# Defined in config/initializers/acts_as_taggable_on.rb
class ActsAsTaggableOn::Tagging
  sig { returns(T.untyped) }
  def touch_taggable; end

  sig { returns(Integer) }
  def increment_tag_custom_counter; end

  sig { returns(Integer) }
  def decrement_tag_custom_counter; end
end

# Extension block of the `votes_for` association defined by acts_as_votable
class ActsAsVotable::Vote::PrivateCollectionProxy
  sig { returns(T::Array[T.untyped]) }
  def voters; end
end

# OmniAuth::AuthHash is a Hashie::Mash; its keys are read through method_missing
class OmniAuth::AuthHash
  sig { returns(T.untyped) }
  def info; end

  sig { returns(T.untyped) }
  def uid; end
end
