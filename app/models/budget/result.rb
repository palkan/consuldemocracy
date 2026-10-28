# typed: strict
class Budget
  class Result
    extend T::Sig

    sig { returns(Budget) }
    attr_accessor :budget

    sig { returns(Budget::Heading) }
    attr_accessor :heading

    sig { returns(T.nilable(Budget::Investment)) }
    attr_accessor :current_investment

    sig { params(budget: Budget, heading: Budget::Heading).void }
    def initialize(budget, heading)
      @budget = budget
      @heading = heading
      @current_investment = T.let(nil, T.nilable(Budget::Investment))
      @money_spent = T.let(nil, T.nilable(Integer))
    end

    sig { void }
    def calculate_winners
      reset_winners
      if @budget.hide_money?
        investments.compatible.update_all(winner: true)
      else
        investments.compatible.each do |investment|
          @current_investment = investment
          set_winner if inside_budget?
        end
      end
    end

    sig { returns(Budget::Investment::PrivateAssociationRelation) }
    def investments
      heading.investments.selected.sort_by_ballots
    end

    sig { returns(T::Boolean) }
    def inside_budget?
      available_budget >= T.must(T.must(@current_investment).price)
    end

    sig { returns(Integer) }
    def available_budget
      total_budget - money_spent
    end

    sig { returns(Integer) }
    def total_budget
      T.must(heading.price)
    end

    sig { returns(Integer) }
    def money_spent
      @money_spent ||= 0
    end

    sig { void }
    def reset_winners
      investments.update_all(winner: false)
    end

    sig { void }
    def set_winner
      current_investment = T.must(@current_investment)
      @money_spent = money_spent + T.must(current_investment.price)
      current_investment.update!(winner: true)
    end

    sig { returns(Budget::Investment::PrivateAssociationRelation) }
    def winners
      investments.where(winner: true)
    end
  end
end
