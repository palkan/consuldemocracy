# typed: strict
class Officing::MenuComponent < ApplicationComponent
  sig { returns(T.nilable(User)) }
  attr_reader :voter_user

  sig { params(voter_user: T.nilable(User)).void }
  def initialize(voter_user:)
    @voter_user = voter_user
  end

  private

    sig { returns(T::Boolean) }
    def vote_collection_shift?
      officer_assignments.voting_days.where(date: Time.current.to_date).any?
    end

    sig { returns(T::Boolean) }
    def final_recount_shift?
      officer_assignments.final.where(date: Time.current.to_date).any?
    end

    sig { returns(Poll::OfficerAssignment::PrivateCollectionProxy) }
    def officer_assignments
      T.must(T.must(current_user).poll_officer).officer_assignments
    end
end
