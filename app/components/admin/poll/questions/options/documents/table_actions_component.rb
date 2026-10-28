# typed: strict
class Admin::Poll::Questions::Options::Documents::TableActionsComponent < ApplicationComponent
  sig { returns(Document) }
  attr_reader :document

  sig { params(document: Document).void }
  def initialize(document)
    @document = document
  end
end
