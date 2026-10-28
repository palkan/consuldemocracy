# typed: strict
module LinkListHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params("*": T.untyped, "**": T.untyped).returns(ActiveSupport::SafeBuffer) }
  def link_list(*, **)
    render T.unsafe(Shared::LinkListComponent).new(*, **)
  end
end
