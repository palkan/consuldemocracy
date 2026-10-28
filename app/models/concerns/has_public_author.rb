# typed: strict
module HasPublicAuthor
  extend T::Sig

  sig { returns(T.nilable(User)) }
  def public_author
    T.must(author).public_activity? ? User.public_for_api.find_by(id: author) : nil
  end
end
