# typed: strict
class Images::FieldsComponent < ApplicationComponent
  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :f

  sig { returns(ApplicationRecord) }
  attr_reader :imageable

  sig { params(f: ActionView::Helpers::FormBuilder, imageable: ApplicationRecord).void }
  def initialize(f, imageable:)
    @f = f
    @imageable = imageable
  end
end
