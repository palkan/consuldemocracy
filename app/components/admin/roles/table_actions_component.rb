# typed: strict
class Admin::Roles::TableActionsComponent < ApplicationComponent
  Role = T.type_alias { T.any(Administrator, Manager, Moderator, SDG::Manager, Valuator) }

  sig { returns(Role) }
  attr_reader :record

  sig { returns(T::Array[Symbol]) }
  attr_reader :actions

  sig { params(record: Role, actions: T::Array[Symbol]).void }
  def initialize(record, actions: [:destroy])
    @record = record
    @actions = actions
  end

  private

    sig { returns(String) }
    def role
      T.must(record.class.name).tableize
    end

    sig { returns(T::Boolean) }
    def already_has_role?
      record.persisted?
    end

    sig { returns(String) }
    def add_user_text
      t("admin.#{role}.#{role.singularize}.add")
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def add_user_path
      {
        controller: "admin/#{role}",
        action: :create,
        user_id: record.user
      }
    end
end
