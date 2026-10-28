# typed: strict
class Documents::DocumentsComponent < ApplicationComponent
  sig { returns(Document::PrivateCollectionProxy) }
  attr_reader :documents

  sig { params(documents: Document::PrivateCollectionProxy).void }
  def initialize(documents)
    @documents = documents
  end

  sig { returns(T::Boolean) }
  def render?
    documents.any?
  end
end
