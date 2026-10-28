# typed: strict
class Documents::DocumentComponent < ApplicationComponent
  sig { returns(Document) }
  attr_reader :document

  sig { returns(T::Boolean) }
  attr_reader :show_destroy_link

  alias_method :show_destroy_link?, :show_destroy_link

  sig { params(document: Document, show_destroy_link: T::Boolean).void }
  def initialize(document, show_destroy_link: false)
    @document = document
    @show_destroy_link = show_destroy_link
  end
end
