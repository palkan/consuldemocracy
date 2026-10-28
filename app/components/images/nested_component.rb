# typed: strict
class Images::NestedComponent < ApplicationComponent
  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :f

  sig { returns(Symbol) }
  attr_reader :image_fields

  sig { params(f: ActionView::Helpers::FormBuilder, image_fields: Symbol).void }
  def initialize(f, image_fields: :image)
    @f = f
    @image_fields = image_fields
  end

  private

    sig { returns(ApplicationRecord) }
    def imageable
      f.object
    end

    sig { returns(String) }
    def note
      t "images.form.note", accepted_content_types: Image.humanized_accepted_content_types,
                            max_file_size: Image.max_file_size
    end
end
