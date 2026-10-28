# typed: strict
class Budget
  class Ballot < ApplicationRecord
    belongs_to :user
    belongs_to :budget
    belongs_to :poll_ballot, class_name: "Poll::Ballot"

    has_many :lines, dependent: :destroy
    has_many :investments, through: :lines
    has_many :groups, -> { distinct }, through: :lines
    has_many :headings, -> { distinct }, through: :groups

    sig { params(investment: Budget::Investment).returns(T.nilable(Budget::Ballot::Line)) }
    def add_investment(investment)
      line = lines.create(investment: investment)

      line if line.persisted?
    end

    sig { returns(Integer) }
    def total_amount_spent
      investments.sum(:price).to_i
    end

    sig { params(group: T.nilable(Budget::Group)).returns(T::Boolean) }
    def has_lines_in_group?(group)
      groups.include?(group)
    end

    sig { params(heading: Budget::Heading).returns(T::Boolean) }
    def wrong_budget?(heading)
      heading.budget_id != budget_id
    end

    sig { params(heading: Budget::Heading).returns(T::Boolean) }
    def different_heading_assigned?(heading)
      other_heading_ids = T.must(heading.group).heading_ids - [heading.id]
      lines.where(heading_id: other_heading_ids).exists?
    end

    sig { params(heading: Budget::Heading).returns(T::Boolean) }
    def valid_heading?(heading)
      !wrong_budget?(heading) && !different_heading_assigned?(heading)
    end

    sig { returns(T::Boolean) }
    def has_lines_with_no_heading?
      T.unsafe(investments).no_heading.any?
    end

    sig { returns(T::Boolean) }
    def has_lines_with_heading?
      T.unsafe(self).heading_id.present?
    end

    sig { params(heading: Budget::Heading).returns(T::Boolean) }
    def has_lines_in_heading?(heading)
      investments.by_heading(heading.id).any?
    end

    sig { params(investment: Budget::Investment).returns(T::Boolean) }
    def has_investment?(investment)
      investment_ids.include?(investment.id)
    end

    sig { params(group: T.nilable(Budget::Group)).returns(T.nilable(Budget::Heading)) }
    def heading_for_group(group)
      return nil unless has_lines_in_group?(group)

      T.must(investments.find_by(group: group)).heading
    end

    sig { returns(T.nilable(T::Boolean)) }
    def casted_offline?
      T.must(budget).poll&.voted_by?(user)
    end

    sig { returns(Budget::VotingStyles::Base) }
    def voting_style
      @voting_style ||= T.let(voting_style_class.new(self), T.nilable(Budget::VotingStyles::Base))
    end
    delegate :amount_available, :amount_available_info, :amount_progress, :amount_spent,
             :amount_spent_info, :amount_limit, :amount_limit_info, :change_vote_info,
             :enough_resources?, :formatted_amount_available, :formatted_amount_limit,
             :formatted_amount_spent, :not_enough_resources_error, :percentage_spent,
             :reason_for_not_being_ballotable, :voted_info,
             to: :voting_style

    private

      sig { returns(T.class_of(Budget::VotingStyles::Base)) }
      def voting_style_class
        "Budget::VotingStyles::#{T.must(T.must(budget).voting_style).camelize}".constantize
      end
  end
end
