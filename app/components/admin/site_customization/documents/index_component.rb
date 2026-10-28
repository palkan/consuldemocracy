# typed: strict
class Admin::SiteCustomization::Documents::IndexComponent < ApplicationComponent
  sig { returns(Document::PrivateRelation) }
  attr_reader :documents

  sig { params(documents: Document::PrivateRelation).void }
  def initialize(documents)
    @documents = documents
  end

  private

    sig { params(document: Document).returns(String) }
    def permanent_document_path(document)
      rails_storage_proxy_path(document.attachment)
    end
end
