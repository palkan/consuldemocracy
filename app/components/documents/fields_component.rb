# typed: strict
class Documents::FieldsComponent < ApplicationComponent
  sig { returns(ActionView::Helpers::FormBuilder) }
  attr_reader :f

  sig { params(f: ActionView::Helpers::FormBuilder).void }
  def initialize(f)
    @f = f
  end

  private

    sig { returns(Document) }
    def document
      f.object
    end
end
