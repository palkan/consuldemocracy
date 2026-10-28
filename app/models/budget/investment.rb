# typed: strict
class Budget
  class Investment < ApplicationRecord
    SORTING_OPTIONS = T.let({ id: "id", supports: "cached_votes_up" }.freeze, T::Hash[Symbol, String])

    include Measurable
    include Taggable
    include Searchable
    include Reclassification
    include Followable
    include Communitable
    include Imageable
    include Mappable
    include Documentable
    include SDG::Relatable
    include HasPublicAuthor

    acts_as_taggable_on :valuation_tags
    acts_as_votable
    acts_as_paranoid column: :hidden_at
    include ActsAsParanoidAliases
    include Relationable
    include Notifiable
    include Filterable
    include Flaggable
    include Milestoneable
    include Randomizable

    translates :title, touch: true
    translates :description, touch: true
    include Globalizable

    audited on: [:update, :destroy]
    has_associated_audits
    translation_class.class_eval do
      audited associated_with: :globalized_model,
              only: Budget::Investment.translated_attribute_names
    end

    belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :budget_investments
    belongs_to :heading
    belongs_to :group
    belongs_to :budget
    belongs_to :administrator

    has_many :valuator_assignments, dependent: :destroy
    has_many :valuators, through: :valuator_assignments

    has_many :valuator_group_assignments, dependent: :destroy
    has_many :valuator_groups, through: :valuator_group_assignments

    has_many :comments, -> { where(valuation: false) }, as: :commentable, inverse_of: :commentable
    has_one :summary_comment, as: :commentable, class_name: "MlSummaryComment", dependent: :destroy
    has_many :valuations, -> { where(valuation: true) },
             as: :commentable,
             inverse_of: :commentable,
             class_name: "Comment"

    validates_translation :title, presence: true, length: { in: 4..Budget::Investment.title_max_length }
    validates_translation :description, presence: true,
                                        length: { maximum: Budget::Investment.description_max_length }

    validates :author, presence: true
    validates :heading_id, presence: true
    validates :unfeasibility_explanation, presence: { if: :unfeasibility_explanation_required? }
    validates :price, presence: { if: :price_required? }
    validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

    scope :sort_by_confidence_score, -> { reorder(confidence_score: :desc, id: :desc) }
    scope :sort_by_ballots,          -> { reorder(ballot_lines_count: :desc, id: :desc) }
    scope :sort_by_price,            -> { reorder(price: :desc, confidence_score: :desc, id: :desc) }
    scope :sort_by_id,               -> { order(id: :desc) }
    scope :sort_by_supports,         -> { order(cached_votes_up: :desc) }

    scope :valuation_open,              -> { where(valuation_finished: false) }
    scope :with_admin,                  -> { where.not(administrator_id: nil) }
    scope :without_admin,               -> { where(administrator_id: nil) }
    scope :without_valuator_group,      -> { where(valuator_group_assignments_count: 0) }
    scope :without_valuator,            -> { without_valuator_group.where(valuator_assignments_count: 0) }
    scope :under_valuation,             -> { valuation_open.valuating.with_admin }
    scope :managed,                     -> { valuation_open.where(valuator_assignments_count: 0).with_admin }
    scope :with_valuator_assignments,   -> { where(valuator_assignments_count: 1..) }
    scope :with_group_assignments,      -> { where(valuator_group_assignments_count: 1..) }
    scope :with_valuation_assignments,  -> { with_valuator_assignments.or(with_group_assignments) }
    scope :valuating,                   -> { valuation_open.with_valuation_assignments }
    scope :visible_to_valuators,        -> { where(visible_to_valuators: true) }
    scope :valuation_finished,          -> { where(valuation_finished: true) }
    scope :valuation_finished_feasible, -> { where(valuation_finished: true, feasibility: "feasible") }
    scope :feasible,                    -> { where(feasibility: "feasible") }
    scope :unfeasible,                  -> { where(feasibility: "unfeasible") }
    scope :not_unfeasible,              -> { where.not(feasibility: "unfeasible") }
    scope :undecided,                   -> { where(feasibility: "undecided") }

    scope :with_supports,      -> { where(cached_votes_up: 1..) }
    scope :selected,           -> { feasible.where(selected: true) }
    scope :compatible,         -> { where(incompatible: false) }
    scope :incompatible,       -> { where(incompatible: true) }
    scope :winners,            -> { selected.compatible.where(winner: true) }
    scope :unselected,         -> { not_unfeasible.where(selected: false) }
    scope :last_week,          -> { where(created_at: 7.days.ago..) }
    scope :sort_by_flags,      -> { order(flags_count: :desc, updated_at: :desc) }
    scope :sort_by_created_at, -> { reorder(created_at: :desc) }
    scope :sort_by_ballot_lines, -> { order(:"budget_ballot_lines.created_at") }

    scope :by_budget,           ->(budget)     { where(budget: budget) }
    scope :by_group,            ->(group_id)   { where(group_id: group_id) }
    scope :by_heading,          ->(heading_id) { where(heading_id: heading_id) }
    scope :by_admin,            ->(admin_id)   { where(administrator_id: admin_id) }
    scope :by_tag,              ->(tag_name)   { tagged_with(tag_name).distinct }
    scope :visible_to_valuator, ->(valuator) do
      visible_to_valuators.where(id: valuator&.assigned_investment_ids)
    end

    scope :for_render, -> { includes(:heading) }
    scope :public_for_api, -> { where(budget: Budget.public_for_api) }

    sig do
      params(valuator_id: T.any(Integer, String, Valuator))
        .returns(T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation))
    end
    def self.by_valuator(valuator_id)
      where(budget_valuator_assignments: { valuator_id: valuator_id }).joins(:valuator_assignments)
    end

    sig do
      params(valuator_group_id: T.any(Integer, String, ValuatorGroup))
        .returns(T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation))
    end
    def self.by_valuator_group(valuator_group_id)
      joins(:valuator_group_assignments)
        .where(budget_valuator_group_assignments: { valuator_group_id: valuator_group_id })
    end

    before_validation :set_responsible_name
    before_validation :set_denormalized_ids
    before_save :calculate_confidence_score
    before_create :set_original_heading_id
    after_save :recalculate_heading_winners

    sig { returns(Integer) }
    def comments_count
      comments.count
    end

    sig { returns(T::Array[Budget::Investment]) }
    def self.sort_by_title
      all.sort_by(&:title)
    end

    sig { params(params: ActionController::Parameters).returns(ActionController::Parameters) }
    def self.filter_params(params)
      params.permit(%i[heading_id group_id administrator_id tag_name valuator_id])
    end

    sig do
      params(
        params: T.any(ActionController::Parameters, T::Hash[T.untyped, T.untyped]),
        current_filter: T.nilable(T.any(String, Symbol))
      ).returns(T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation))
    end
    def self.scoped_filter(params, current_filter)
      budget  = Budget.find_by_slug_or_id params[:budget_id]
      results = Investment.by_budget(budget)

      if params[:min_total_supports].present?
        results = results.where("cached_votes_up + physical_votes >= ?", params[:min_total_supports])
      end
      if params[:max_total_supports].present?
        results = results.where("cached_votes_up + physical_votes <= ?", params[:max_total_supports])
      end

      results = results.where(group_id: params[:group_id])            if params[:group_id].present?
      results = results.by_heading(params[:heading_id])               if params[:heading_id].present?
      results = results.by_tag(params[:tag_name])                     if params[:tag_name].present?
      results = results.by_tag(params[:milestone_tag_name])           if params[:milestone_tag_name].present?
      results = results.by_valuator(params[:valuator_id])             if params[:valuator_id].present?
      results = results.by_valuator_group(params[:valuator_group_id]) if params[:valuator_group_id].present?
      results = results.by_admin(params[:administrator_id])           if params[:administrator_id].present?

      results = results.search_by_title_or_id(params[:title_or_id].strip) if params[:title_or_id]
      results = advanced_filters(params, results) if params[:advanced_filters].present?
      results = results.send(current_filter) if current_filter.present?

      results.includes(:heading, :group, :budget, administrator: :user, valuators: :user)
    end

    sig do
      params(
        params: T.any(ActionController::Parameters, T::Hash[T.untyped, T.untyped]),
        results: T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation)
      ).returns(T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation))
    end
    def self.advanced_filters(params, results)
      results = results.without_admin      if params[:advanced_filters].include?("without_admin")
      results = results.without_valuator   if params[:advanced_filters].include?("without_valuator")
      results = results.under_valuation    if params[:advanced_filters].include?("under_valuation")
      results = results.valuation_finished if params[:advanced_filters].include?("valuation_finished")
      results = results.winners            if params[:advanced_filters].include?("winners")

      ids = T.let([], T::Array[Integer])
      ids += results.valuation_finished_feasible.ids if params[:advanced_filters].include?("feasible")
      ids += results.where(selected: true).ids       if params[:advanced_filters].include?("selected")
      ids += results.undecided.ids                   if params[:advanced_filters].include?("undecided")
      ids += results.unfeasible.ids                  if params[:advanced_filters].include?("unfeasible")
      results = results.where(id: ids) if ids.any?
      results
    end

    sig do
      params(params: T.any(ActionController::Parameters, T::Hash[T.untyped, T.untyped]))
        .returns(T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation,
                       T::Array[Budget::Investment]))
    end
    def self.order_filter(params)
      sorting_key = params[:sort_by]&.downcase&.to_sym
      allowed_sort_option = SORTING_OPTIONS[sorting_key]
      direction = params[:direction] == "desc" ? "desc" : "asc"

      if allowed_sort_option.present?
        order("#{allowed_sort_option} #{direction}")
      elsif sorting_key == :title
        direction == "asc" ? sort_by_title : sort_by_title.reverse
      else
        order(cached_votes_up: :desc).order(id: :desc)
      end
    end

    sig do
      params(
        budget: Budget,
        params: T.any(ActionController::Parameters, T::Hash[T.untyped, T.untyped]),
        results: T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation)
      ).returns(T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation))
    end
    def self.limit_results(budget, params, results)
      max_per_heading = params[:max_per_heading].to_i
      return results if max_per_heading <= 0

      ids = T.let([], T::Array[Integer])
      budget.headings.ids.each do |hid|
        ids += Investment.where(heading_id: hid).order(confidence_score: :desc).limit(max_per_heading).ids
      end

      results.where(id: ids)
    end

    sig do
      params(title_or_id: String)
        .returns(T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation))
    end
    def self.search_by_title_or_id(title_or_id)
      with_joins = with_translations(Globalize.fallbacks(I18n.locale))

      with_joins.where(id: title_or_id)
                .or(with_joins.where("budget_investment_translations.title ILIKE ?", "%#{title_or_id}%"))
    end

    sig { returns(T::Hash[T.nilable(String), String]) }
    def searchable_values
      {
        T.must(author).username => "B",
        T.must(heading).name => "B",
        tag_list.join(" ") => "B"
      }.merge(searchable_globalized_values)
    end

    sig do
      params(terms: String)
        .returns(T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation))
    end
    def self.search(terms)
      pg_search(terms)
    end

    sig do
      params(heading: T.nilable(T.any(Integer, String)))
        .returns(T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation))
    end
    def self.by_heading(heading)
      where(heading_id: heading == "all" ? nil : heading.presence)
    end

    sig { returns(T::Boolean) }
    def undecided?
      feasibility == "undecided"
    end

    sig { returns(T::Boolean) }
    def feasible?
      feasibility == "feasible"
    end

    sig { returns(T::Boolean) }
    def unfeasible?
      feasibility == "unfeasible"
    end

    sig { returns(T::Boolean) }
    def unfeasibility_explanation_required?
      unfeasible? && valuation_finished?
    end

    sig { returns(T::Boolean) }
    def price_required?
      feasible? && valuation_finished? && T.must(budget).show_money?
    end

    sig { returns(T::Boolean) }
    def unfeasible_email_pending?
      unfeasible_email_sent_at.blank? && unfeasible? && valuation_finished?
    end

    sig { returns(Integer) }
    def total_votes
      T.must(cached_votes_up) + T.must(physical_votes)
    end

    sig { returns(String) }
    def code
      administrator = self.administrator
      "#{created_at.strftime("%Y")}-#{id}" + (administrator.present? ? "-A#{administrator.id}" : "")
    end

    sig { void }
    def send_unfeasible_email
      Mailer.budget_investment_unfeasible(self).deliver_later
      update!(unfeasible_email_sent_at: Time.current)
    end

    sig { params(user: T.nilable(User)).returns(T.nilable(Symbol)) }
    def reason_for_not_being_selectable_by(user)
      return permission_problem(user) if permission_problem?(user)
      return :different_heading_assigned unless valid_heading?(T.must(user))

      :no_selecting_allowed unless T.must(budget).selecting?
    end

    sig { params(user: T.nilable(User), ballot: Budget::Ballot).returns(T.nilable(Symbol)) }
    def reason_for_not_being_ballotable_by(user, ballot)
      return permission_problem(user)    if permission_problem?(user)
      return :not_selected               unless selected?
      return :no_ballots_allowed         unless T.must(budget).balloting?
      return :different_heading_assigned unless ballot.valid_heading?(T.must(heading))
      return :casted_offline             if ballot.casted_offline?

      ballot.reason_for_not_being_ballotable(self)
    end

    sig { params(user: T.nilable(User)).returns(T.nilable(Symbol)) }
    def permission_problem(user)
      return :not_logged_in unless user
      return :organization  if user.organization?
      return :not_verified  unless user.level_two_or_three_verified?

      nil
    end

    sig { params(user: T.nilable(User)).returns(T::Boolean) }
    def permission_problem?(user)
      permission_problem(user).present?
    end

    sig { params(user: T.nilable(User)).returns(T::Boolean) }
    def selectable_by?(user)
      reason_for_not_being_selectable_by(user).blank?
    end

    sig { params(user: User).returns(T::Boolean) }
    def valid_heading?(user)
      voted_in?(T.must(heading), user) || can_vote_in_another_heading?(user)
    end

    sig { params(user: User).returns(T::Boolean) }
    def can_vote_in_another_heading?(user)
      group = T.must(self.group)
      user.headings_voted_within_group(group).count < T.must(group.max_votable_headings)
    end

    sig { params(heading: Budget::Heading, user: User).returns(T::Boolean) }
    def voted_in?(heading, user)
      user.headings_voted_within_group(T.must(group)).where(id: heading.id).exists?
    end

    sig { params(user: User).void }
    def register_selection(user)
      user.with_lock { vote_by(voter: user, vote: "yes") } if selectable_by?(user)
    end

    sig { void }
    def calculate_confidence_score
      self.confidence_score = ScoreCalculator.confidence_score(total_votes, total_votes).to_i
    end

    sig { void }
    def recalculate_heading_winners
      Budget::Result.new(T.must(budget), T.must(heading)).calculate_winners if saved_change_to_incompatible?
    end

    sig { void }
    def set_responsible_name
      self.responsible_name = author&.document_number if author&.document_number.present?
    end

    sig { returns(T::Boolean) }
    def should_show_aside?
      budget = T.must(self.budget)

      (budget.selecting? && !unfeasible?) ||
        (budget.balloting? && feasible?) ||
        (budget.valuating? && !unfeasible?)
    end

    sig { returns(T::Boolean) }
    def should_show_votes?
      T.must(budget).selecting?
    end

    sig { returns(T::Boolean) }
    def should_show_vote_count?
      T.must(budget).valuating?
    end

    sig { returns(T::Boolean) }
    def should_show_ballots?
      T.must(budget).balloting? && selected?
    end

    sig { returns(T::Boolean) }
    def should_show_price?
      budget = T.must(self.budget)

      selected? && price.present? && budget.published_prices? && budget.show_money?
    end

    sig { returns(T::Boolean) }
    def should_show_price_explanation?
      should_show_price? && price_explanation.present?
    end

    sig { returns(T::Boolean) }
    def should_show_unfeasibility_explanation?
      unfeasible? && valuation_finished? && unfeasibility_explanation.present?
    end

    sig { returns(T.nilable(String)) }
    def formatted_price
      T.must(budget).formatted_amount(price)
    end

    sig do
      params(
        _budget: T.nilable(Budget),
        params: T.any(ActionController::Parameters, T::Hash[T.untyped, T.untyped]),
        current_filter: T.nilable(T.any(String, Symbol))
      )
        .returns(T.any(Budget::Investment::PrivateRelation, Budget::Investment::PrivateAssociationRelation))
    end
    def self.apply_filters_and_search(_budget, params, current_filter = nil)
      investments = all
      investments = investments.send(current_filter)             if current_filter.present?
      investments = investments.by_heading(params[:heading_id])  if params[:heading_id].present?
      investments = investments.search(params[:search])          if params[:search].present?
      investments = investments.filter_by(params[:advanced_search])
      investments
    end

    sig { returns(T.nilable(String)) }
    def assigned_valuators
      valuators.map(&:description_or_name).compact.join(", ").presence
    end

    sig { returns(T.nilable(String)) }
    def assigned_valuation_groups
      valuator_groups.map(&:name).compact.join(", ").presence
    end

    sig { params(status_id: T.any(Integer, String)).returns(T::Array[Budget::Investment]) }
    def self.with_milestone_status_id(status_id)
      includes(milestones: :translations).select do |investment|
        investment.milestone_status_id == status_id.to_i
      end
    end

    sig { returns(T.nilable(Integer)) }
    def milestone_status_id
      milestones.published.with_status.order_by_publication_date.last&.status_id
    end

    sig { returns(T::Array[T.any(Valuator, Administrator)]) }
    def admin_and_valuator_users_associated
      valuator_users = T.let((valuator_groups.map(&:valuators) + valuators).flatten,
                             T::Array[T.nilable(T.any(Valuator, Administrator))])
      all_users = valuator_users << administrator
      all_users.compact.uniq
    end

    private

      sig { void }
      def set_denormalized_ids
        self.group_id = heading&.group_id if will_save_change_to_heading_id?
        self.budget_id ||= heading&.group&.budget_id
      end

      sig { void }
      def set_original_heading_id
        self.original_heading_id = heading_id
      end

      sig { returns(T::Hash[T.nilable(String), String]) }
      def searchable_translations_definitions
        { title => "A",
          description => "D" }
      end
  end
end
