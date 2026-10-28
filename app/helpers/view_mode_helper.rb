# typed: strict
module ViewModeHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { returns(T::Boolean) }
  def default_view_mode?
    params[:view] != "minimal"
  end
end
