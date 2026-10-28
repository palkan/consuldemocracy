# typed: strict
module OfficersHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { returns(T::Boolean) }
  def no_shifts?
    T.must(T.must(current_user).poll_officer).officer_assignments.where(date: Time.current.to_date).blank?
  end
end
