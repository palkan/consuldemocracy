# typed: strict
module PollRecountsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(booth_assignment: Poll::BoothAssignment).returns(T.nilable(Numeric)) }
  def total_recounts_by_booth(booth_assignment)
    if booth_assignment.recounts.any?
      booth_assignment.recounts.sum(:total_amount) +
        booth_assignment.recounts.sum(:white_amount) +
        booth_assignment.recounts.sum(:null_amount)
    end
  end
end
