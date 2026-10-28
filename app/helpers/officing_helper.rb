# typed: strict
module OfficingHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig do
    params(
      officer_assignments: T::Enumerable[Poll::OfficerAssignment]
    ).returns(ActiveSupport::SafeBuffer)
  end
  def booths_for_officer_select_options(officer_assignments)
    options = officer_assignments.map do |oa|
      [T.must(T.must(oa.booth_assignment).booth).name.to_s, oa.id]
    end
    options.sort_by! { |x| x[0] }
    options_for_select(options, params[:oa])
  end
end
