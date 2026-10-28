# typed: strict
class Verification::Management::ManagedUser
  extend T::Sig
  include ActiveModel::Model

  sig { params(document_type: T.nilable(String), document_number: T.nilable(String)).returns(User) }
  def self.find(document_type, document_number)
    User.where.not(document_number: nil)
        .find_or_initialize_by(document_type: document_type,
                               document_number: document_number)
  end
end
