# typed: strict
class DirectUploads::FieldsComponent < ApplicationComponent
  sig { returns(DirectUpload) }
  attr_reader :direct_upload

  sig { params(direct_upload: DirectUpload).void }
  def initialize(direct_upload)
    @direct_upload = direct_upload
  end

  private

    sig { returns(T.nilable(String)) }
    def fields_content
      form_for resource, url: false do |form|
        case attachable.class.name
        when "Document"
          return document_fields(form)
        when "Image"
          return image_fields(form)
        end
      end
    end

    sig { params(form: ActionView::Helpers::FormBuilder).returns(T.nilable(String)) }
    def document_fields(form)
      form.fields_for :documents, attachable, child_index: nested_index do |documents_builder|
        render Documents::FieldsComponent.new(documents_builder)
      end
    end

    sig { params(form: ActionView::Helpers::FormBuilder).returns(T.nilable(String)) }
    def image_fields(form)
      form.fields_for image_fields_name, attachable, child_index: nested_index do |image_builder|
        render Images::FieldsComponent.new(image_builder, imageable: resource)
      end
    end

    sig { returns(Integer) }
    def nested_index
      T.cast(SecureRandom.random_number(10**12), Integer)
    end

    sig { returns(Symbol) }
    def image_fields_name
      if resource.class.reflect_on_association(:image)
        :image
      else
        :images
      end
    end

    sig { returns(ApplicationRecord) }
    def resource
      direct_upload.resource
    end

    sig { returns(T.any(Document, Image)) }
    def attachable
      T.must(direct_upload.relation)
    end
end
