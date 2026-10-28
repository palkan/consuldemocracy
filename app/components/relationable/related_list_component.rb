# typed: strict
class Relationable::RelatedListComponent < ApplicationComponent
  sig { returns(Relationable) }
  attr_reader :relationable

  sig { params(relationable: Relationable).void }
  def initialize(relationable)
    @relationable = relationable
    @related_contents = T.let(nil, T.nilable(Kaminari::PaginatableArray))
  end

  sig { returns(T::Boolean) }
  def render?
    related_contents.present?
  end

  private

    sig { returns(Kaminari::PaginatableArray) }
    def related_contents
      @related_contents ||= Kaminari.paginate_array(relationable.relationed_contents)
                                    .page(params[:page])
                                    .per(5)
    end
end
