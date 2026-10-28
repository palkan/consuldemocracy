# typed: strict
class Admin::Poll::Questions::Options::Documents::IndexComponent < ApplicationComponent
  sig { returns(::Poll::Question::Option) }
  attr_reader :option

  sig { params(option: ::Poll::Question::Option).void }
  def initialize(option)
    @option = option
    @documents = T.let(nil, T.nilable(Document::PrivateCollectionProxy))
  end

  private

    sig { returns(Document::PrivateCollectionProxy) }
    def documents
      @documents ||= @option.class.find(@option.id).documents
    end
end
