# typed: strict
module Dashboard::GroupSupports
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }
  requires_ancestor { Dashboard::ExpectsDateRange }

  abstract!

  sig { params(attribute: Symbol).returns(T::Hash[T.any(String, Date), T.untyped]) }
  def grouped_supports(attribute)
    supports.group_by { |v| grouping_key_for(v[attribute].in_time_zone.to_date) }
  end

  sig { params(date: Date).returns(T.any(String, Date)) }
  def grouping_key_for(date)
    return calculate_week(date) if params[:group_by] == "week"
    return "#{date.year}-#{date.month}" if params[:group_by] == "month"

    date
  end

  sig do
    params(grouped_votes: T::Hash[T.any(String, Date), T.untyped])
      .returns(T::Hash[T.any(String, Date), T.untyped])
  end
  def accumulate_supports(grouped_votes)
    grouped_votes.each do |group, votes|
      grouped_votes[group] = votes.reduce(0) { |sum, vote| sum + vote.vote_weight }
    end

    accumulated = 0
    grouped_votes.each do |k, v|
      accumulated += v
      grouped_votes[k] = accumulated
    end
  end

  sig do
    params(grouped_votes: T::Hash[T.any(String, Date), T.untyped])
      .returns(T::Hash[T.any(String, Date), T.untyped])
  end
  def fill_holes(grouped_votes)
    complete_grouped_votes = {}

    (start_date(T.must(proposal.published_at).to_date)..end_date).each do |date|
      key = grouping_key_for(date)
      complete_grouped_votes[key] = if grouped_votes.key? key
                                      grouped_votes[key]
                                    else
                                      []
                                    end
    end

    complete_grouped_votes
  end

  private

    sig { params(date: Date).returns(String) }
    def calculate_week(date)
      week = date.cweek
      year = calculate_year_of_week(date)
      "#{week}/#{year}"
    end

    sig { params(date: Date).returns(Integer) }
    def calculate_year_of_week(date)
      year = date.year
      if first_week_of_year?(date) && date.end_of_week.year != date.year
        year = year + 1
      elsif last_week_of_year?(date) && date.beginning_of_week.year != date.year
        year = year - 1
      end
      year
    end

    sig { params(date: Date).returns(T::Boolean) }
    def first_week_of_year?(date)
      date.cweek == 1
    end

    sig { params(date: Date).returns(T::Boolean) }
    def last_week_of_year?(date)
      date.cweek == 52 || date.cweek == 53
    end

    sig { abstract.returns(T.any(T::Array[Vote], Vote::PrivateRelation)) }
    def supports; end
end
