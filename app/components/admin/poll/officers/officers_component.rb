# typed: strict
class Admin::Poll::Officers::OfficersComponent < ApplicationComponent
  Officers = T.type_alias { T.any(T::Array[::Poll::Officer], ::Poll::Officer::PrivateRelation) }

  sig { returns(Officers) }
  attr_reader :officers

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :options

  sig { params(officers: Officers, options: T.untyped).void }
  def initialize(officers, **options)
    @officers = officers
    @options = options
  end

  private

    sig { params(officer: ::Poll::Officer).returns(T::Hash[Symbol, T.untyped]) }
    def add_user_path(officer)
      {
        controller: "admin/poll/officers",
        action: :create,
        user_id: officer.user_id
      }
    end
end
