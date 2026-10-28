# typed: strict
module Statisticable
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { Object }

  PARTICIPATIONS = T.let(%w[gender age geozone].freeze, T::Array[String])

  # Not checked at runtime: specs use doubles as resources
  T::Sig::WithoutRuntime.sig { returns(T.any(Budget, Poll)) }
  attr_reader :resource

  sig { returns(T::Boolean) }
  attr_reader :cache

  module ClassMethods
    extend T::Helpers
    extend T::Sig

    requires_ancestor { Module }

    sig { returns(T::Array[Symbol]) }
    def stats_methods
      base_stats_methods + gender_methods + age_methods + geozone_methods
    end

    sig { returns(T::Array[Symbol]) }
    def base_stats_methods
      %i[total_participants participations] + participation_check_methods
    end

    sig { returns(T::Array[Symbol]) }
    def participation_check_methods
      PARTICIPATIONS.map { |participation| :"#{participation}?" }
    end

    sig { returns(T::Array[Symbol]) }
    def gender_methods
      %i[total_male_participants total_female_participants male_percentage female_percentage]
    end

    sig { returns(T::Array[Symbol]) }
    def age_methods
      [:participants_by_age]
    end

    sig { returns(T::Array[Symbol]) }
    def geozone_methods
      %i[participants_by_geozone total_no_demographic_data]
    end

    sig { params(method_names: Symbol).void }
    def stats_cache(*method_names)
      method_names.each do |method_name|
        alias_method :"raw_#{method_name}", method_name

        define_method method_name do
          T.bind(self, Statisticable).send(:stats_cache, method_name) { send(:"raw_#{method_name}") }
        end
      end
    end
  end

  T::Sig::WithoutRuntime.sig { params(resource: T.any(Budget, Poll), cache: T::Boolean).void }
  def initialize(resource, cache: true)
    @resource = resource
    @cache = cache
  end

  sig { void }
  def generate
    User.transaction do
      begin
        define_singleton_method :participants do
          create_participants_table unless participants_table_created?
          participants_class.all
        end

        stats_methods.each { |stat_name| send(stat_name) }
      ensure
        define_singleton_method :participants do
          participants_from_original_table
        end
      end

      drop_participants_table
    end
  end

  sig { returns(T::Array[Symbol]) }
  def stats_methods
    base_stats_methods + participation_methods
  end

  sig { returns(T::Array[String]) }
  def participations
    PARTICIPATIONS.select { |participation| send("#{participation}?") }
  end

  sig { returns(T::Boolean) }
  def gender?
    participants.male.any? || participants.female.any?
  end

  sig { returns(T::Boolean) }
  def age?
    participants.between_ages(
      age_groups.flatten.min,
      age_groups.flatten.max,
      at_time: participation_date
    ).any?
  end

  sig { returns(T::Boolean) }
  def geozone?
    participants.where(geozone: geozones).any?
  end

  sig { returns(User::PrivateRelation) }
  def participants
    @participants ||= T.let(User.unscoped.where(id: participant_ids), T.nilable(User::PrivateRelation))
  end
  alias_method :participants_from_original_table, :participants

  sig { returns(Integer) }
  def total_male_participants
    participants.male.count
  end

  sig { returns(Integer) }
  def total_female_participants
    participants.female.count
  end

  sig { returns(Integer) }
  def total_no_demographic_data
    participants.where("gender IS NULL OR date_of_birth IS NULL OR geozone_id IS NULL").count
  end

  sig { returns(Float) }
  def male_percentage
    calculate_percentage(total_male_participants, total_participants_with_gender)
  end

  sig { returns(Float) }
  def female_percentage
    calculate_percentage(total_female_participants, total_participants_with_gender)
  end

  sig { returns(T::Hash[String, T::Hash[Symbol, T.any(String, Integer, Float)]]) }
  def participants_by_age
    age_groups.to_h do |start, finish|
      count = participants.between_ages(start, finish, at_time: participation_date).count

      [
        "#{start} - #{finish}",
        {
          range: range_description(start, finish),
          count: count,
          percentage: calculate_percentage(count, total_participants)
        }
      ]
    end
  end

  sig { returns(T::Hash[T.nilable(String), T::Hash[Symbol, T.any(Integer, Float)]]) }
  def participants_by_geozone
    geozones.to_h do |geozone|
      count = participants.where(geozone: geozone).count

      [
        geozone.name,
        {
          count: count,
          percentage: calculate_percentage(count, total_participants)
        }
      ]
    end
  end

  sig { params(fraction: Integer, total: Integer).returns(Float) }
  def calculate_percentage(fraction, total)
    return 0.0 if total.zero?

    T.cast((fraction * 100.0 / total).round(3), Float)
  end

  sig { returns(T.nilable(T::Boolean)) }
  def advanced?
    resource.advanced_stats_enabled?
  end

  private

    sig { returns(T::Array[Symbol]) }
    def base_stats_methods
      T.cast(self.class, Statisticable::ClassMethods).base_stats_methods
    end

    sig { returns(T::Array[Symbol]) }
    def participation_methods
      participations.map { |participation| self.class.send("#{participation}_methods") }.flatten
    end

    sig { void }
    def create_participants_table
      User.connection.create_table(
        participants_table_name,
        temporary: true,
        as: participants_from_original_table.to_sql
      )
      User.connection.add_index participants_table_name, :date_of_birth
      User.connection.add_index participants_table_name, :geozone_id
      @participants_table_created = T.let(true, T.nilable(T::Boolean))
    end

    sig { void }
    def drop_participants_table
      User.connection.drop_table(participants_table_name, if_exists: true, temporary: true)
      @participants_table_created = T.let(false, T.nilable(T::Boolean))
    end

    sig { returns(String) }
    def participants_table_name
      @participants_table_name ||= T.let(
        "participants_#{resource.class.table_name}_#{resource.id}",
        T.nilable(String)
      )
    end

    sig { returns(T.class_of(User)) }
    def participants_class
      @participants_class ||= T.let(
        Class.new(User).tap { |klass| klass.table_name = participants_table_name },
        T.nilable(T.class_of(User))
      )
    end

    sig { returns(T::Boolean) }
    def participants_table_created?
      @participants_table_created.present?
    end

    sig { returns(Integer) }
    def total_participants_with_gender
      @total_participants_with_gender ||= T.let(
        participants.where.not(gender: nil).distinct.count,
        T.nilable(Integer)
      )
    end

    sig { returns(T::Array[[Integer, Integer]]) }
    def age_groups
      [[16, 19],
       [20, 24],
       [25, 29],
       [30, 34],
       [35, 39],
       [40, 44],
       [45, 49],
       [50, 54],
       [55, 59],
       [60, 64],
       [65, 69],
       [70, 74],
       [75, 79],
       [80, 84],
       [85, 89],
       [90, 300]]
    end

    sig { returns(Geozone::PrivateRelation) }
    def geozones
      Geozone.order(:name)
    end

    sig { params(start: Integer, finish: Integer).returns(String) }
    def range_description(start, finish)
      if finish > 200
        I18n.t("stats.age_more_than", start: start)
      else
        I18n.t("stats.age_range", start: start, finish: finish)
      end
    end

    sig { params(key: T.any(String, Symbol), block: T.proc.returns(T.untyped)).returns(T.untyped) }
    def stats_cache(key, &block)
      if cache
        Rails.cache.fetch(full_cache_key_for(key), expires_at: Date.current.end_of_day, &block)
      else
        block.call
      end
    end
end
