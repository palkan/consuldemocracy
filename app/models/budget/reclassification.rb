# typed: strict
class Budget
  module Reclassification
    extend ActiveSupport::Concern
    extend T::Helpers
    extend T::Sig

    requires_ancestor { Budget::Investment }

    included do
      after_save :check_for_reclassification
    end

    sig { void }
    def check_for_reclassification
      if saved_change_to_heading?
        log_heading_change
        store_reclassified_votes("heading_changed")
        remove_reclassified_votes
      elsif marked_as_unfeasible?
        store_reclassified_votes("unfeasible")
        remove_reclassified_votes
      end
    end

    sig { returns(T.nilable(T::Boolean)) }
    def saved_change_to_heading?
      T.must(budget).balloting? && saved_change_to_heading_id?
    end

    sig { returns(T.nilable(T::Boolean)) }
    def marked_as_unfeasible?
      T.must(budget).balloting? && saved_change_to_feasibility? && unfeasible?
    end

    sig { void }
    def log_heading_change
      update_column(:previous_heading_id, heading_id_before_last_save)
    end

    sig { params(reason: String).void }
    def store_reclassified_votes(reason)
      ballot_lines_for_investment.order(:id).each do |line|
        attrs = { user: T.must(line.ballot).user, investment: self, reason: reason }
        Budget::ReclassifiedVote.create!(attrs)
      end
    end

    sig { void }
    def remove_reclassified_votes
      ballot_lines_for_investment.destroy_all
    end

    sig { returns(Budget::Ballot::Line::PrivateRelation) }
    def ballot_lines_for_investment
      Budget::Ballot::Line.by_investment(id)
    end
  end
end
