# typed: strict
module Ahoy
  class Chart
    extend T::Sig

    sig { returns(T.any(String, Symbol)) }
    attr_reader :event_name

    delegate :count, to: :records
    delegate :t, to: "ApplicationController.helpers"

    sig { params(event_name: T.any(String, Symbol)).void }
    def initialize(event_name)
      @event_name = event_name
    end

    sig { returns(T::Array[Symbol]) }
    def self.active_event_names
      event_names_with_collections.select { |name, collection| collection.any? }.keys.sort_by do |event_name|
        new(event_name).title
      end
    end

    sig { returns(T::Hash[Symbol, ActiveRecord::Relation]) }
    def self.event_names_with_collections
      {
        budget_investment_created: Budget::Investment.with_hidden,
        debate_created: Debate.with_hidden,
        legislation_annotation_created: Legislation::Annotation.with_hidden,
        legislation_answer_created: Legislation::Answer.with_hidden,
        level_3_user: User.with_hidden.level_three_verified,
        proposal_created: Proposal.with_hidden
      }
    end

    sig { returns(Ahoy::DataSource::Data) }
    def self.active_events_data_points
      Ahoy::DataSource.build do |data_source|
        active_event_names.map { |event_name| new(event_name) }.each do |chart|
          data_source.add chart.title, chart.data
        end
      end
    end

    sig { returns(Ahoy::DataSource::Data) }
    def data_points
      Ahoy::DataSource.build do |data_source|
        data_source.add title, data
      end
    end

    sig { returns(String) }
    def title
      t("admin.stats.graph.#{event_name}")
    end

    sig { returns(T::Hash[Date, Integer]) }
    def data
      records_by_day.count
    end

    private

      sig { returns(T.nilable(ActiveRecord::Relation)) }
      def records
        case event_name.to_sym
        when :budget_investment_supported
          Vote.where(votable_type: "Budget::Investment")
        when :visits
          Visit.all
        else
          self.class.event_names_with_collections[event_name.to_sym]
        end
      end

      sig { returns(ActiveRecord::Relation) }
      def records_by_day
        raise "Unknown event #{event_name}" unless records.respond_to?(:group_by_day)

        T.must(records).group_by_day(date_field)
      end

      sig { returns(Symbol) }
      def date_field
        if event_name.to_sym == :level_3_user
          :verified_at
        else
          :created_at
        end
      end
  end
end
