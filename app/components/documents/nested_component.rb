# typed: strict
class Documents::NestedComponent < ApplicationComponent
  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :f

  sig { params(f: ActionView::Helpers::FormBuilder).void }
  def initialize(f)
    @f = f
  end

  private

    sig { returns(T.untyped) }
    def documentable
      f.object
    end

    sig { returns(Integer) }
    def max_documents_allowed
      documentable.class.max_documents_allowed
    end

    sig { returns(String) }
    def note
      t "documents.form.note", max_documents_allowed: max_documents_allowed,
                               accepted_content_types: Document.humanized_accepted_content_types,
                               max_file_size: documentable.class.max_file_size
    end

    sig { returns(T::Boolean) }
    def max_documents_allowed?
      documentable.documents.count >= max_documents_allowed
    end
end
