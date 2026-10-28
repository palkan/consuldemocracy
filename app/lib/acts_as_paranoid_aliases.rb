# typed: strict
module ActsAsParanoidAliases
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ApplicationRecord }

  sig { params(base: T.class_of(ApplicationRecord)).void }
  def self.included(base)
    base.extend(ClassMethods)
  end

  sig { returns(T.anything) }
  def hide
    return false if hidden?

    update_attribute(:hidden_at, Time.current)
    after_hide
  end

  sig { returns(T::Boolean) }
  def hidden?
    deleted?
  end

  sig { void }
  def after_hide
  end

  sig { returns(T::Boolean) }
  def confirmed_hide?
    public_send(:confirmed_hide_at).present?
  end

  sig { returns(T::Boolean) }
  def confirm_hide
    update_attribute(:confirmed_hide_at, Time.current)
  end

  sig { params(opts: T::Hash[Symbol, T.untyped]).returns(T.anything) }
  def restore(opts = {})
    return false unless hidden?

    super
    model = T.cast(self.class, T.class_of(ApplicationRecord))
    update_attribute(:confirmed_hide_at, nil) if model.column_names.include? "confirmed_hide_at"
    after_restore
  end

  sig { void }
  def after_restore
  end

  module ClassMethods
    extend T::Sig
    extend T::Helpers

    requires_ancestor { ActiveRecord::Querying }

    sig { returns(T.untyped) }
    def with_confirmed_hide
      where.not(confirmed_hide_at: nil)
    end

    sig { returns(T.untyped) }
    def without_confirmed_hide
      where(confirmed_hide_at: nil)
    end

    sig { returns(T.untyped) }
    def with_hidden
      with_deleted
    end

    sig { returns(T.untyped) }
    def only_hidden
      only_deleted
    end

    sig { params(ids: T.untyped).void }
    def hide_all(ids)
      return if ids.blank?

      where(id: ids).each(&:hide)
    end

    sig { params(ids: T.untyped).void }
    def restore_all(ids)
      return if ids.blank?

      only_hidden.where(id: ids).find_each(&:restore)
    end
  end
end
