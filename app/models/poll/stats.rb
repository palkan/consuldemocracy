# typed: strict
class Poll::Stats
  include Statisticable
  extend T::Sig

  sig { returns(Poll) }
  def poll
    T.cast(resource, Poll)
  end

  CHANNELS = T.let(Poll::Voter::VALID_ORIGINS, T::Array[String])

  sig { returns(T::Array[Symbol]) }
  def self.stats_methods
    super +
      %i[total_valid_votes total_white_votes total_null_votes
         total_participants_web total_web_valid total_web_white total_web_null
         total_participants_booth total_booth_valid total_booth_white total_booth_null
         total_participants_letter total_letter_valid total_letter_white total_letter_null
         total_participants_web_percentage total_participants_booth_percentage
         total_participants_letter_percentage
         valid_percentage_web valid_percentage_booth valid_percentage_letter total_valid_percentage
         white_percentage_web white_percentage_booth white_percentage_letter total_white_percentage
         null_percentage_web null_percentage_booth null_percentage_letter total_null_percentage]
  end

  sig { returns(Integer) }
  def total_participants
    total_participants_web + total_participants_booth
  end

  sig { returns(T.nilable(ActiveSupport::TimeWithZone)) }
  def participation_date
    poll.ends_at
  end

  sig { returns(T::Array[String]) }
  def channels
    CHANNELS.select { |channel| send(:"total_participants_#{channel}") > 0 }
  end

  CHANNELS.each do |channel|
    define_method :"total_participants_#{channel}" do
      T.bind(self, Poll::Stats)

      send(:"total_#{channel}_valid") +
        send(:"total_#{channel}_white") +
        send(:"total_#{channel}_null")
    end

    define_method :"total_participants_#{channel}_percentage" do
      T.bind(self, Poll::Stats)

      calculate_percentage(send(:"total_participants_#{channel}"), total_participants)
    end
  end

  sig { returns(Integer) }
  def total_web_valid
    voters.where(origin: "web", user_id: poll.answers.select(:author_id).distinct).count
  end

  sig { returns(Integer) }
  def total_web_white
    voters.where(origin: "web").count - total_web_valid
  end

  sig { returns(Integer) }
  def total_web_null
    0
  end

  sig { returns(Integer) }
  def total_booth_valid
    T.cast(recounts.sum(:total_amount), Integer)
  end

  sig { returns(Integer) }
  def total_booth_white
    T.cast(recounts.sum(:white_amount), Integer)
  end

  sig { returns(Integer) }
  def total_booth_null
    T.cast(recounts.sum(:null_amount), Integer)
  end

  sig { returns(Integer) }
  def total_letter_valid
    voters.where(origin: "letter").count # TODO: count only valid votes
  end

  sig { returns(Integer) }
  def total_letter_white
    0 # TODO
  end

  sig { returns(Integer) }
  def total_letter_null
    0 # TODO
  end

  %i[valid white null].each do |type|
    CHANNELS.each do |channel|
      define_method :"#{type}_percentage_#{channel}" do
        T.bind(self, Poll::Stats)

        calculate_percentage(send(:"total_#{channel}_#{type}"), send(:"total_#{type}_votes"))
      end
    end

    define_method :"total_#{type}_votes" do
      T.bind(self, Poll::Stats)

      send(:"total_web_#{type}") + send(:"total_booth_#{type}")
    end

    define_method :"total_#{type}_percentage" do
      T.bind(self, Poll::Stats)

      calculate_percentage(send(:"total_#{type}_votes"), total_participants)
    end
  end

  sig { returns(Integer) }
  def total_no_demographic_data
    super + total_unregistered_booth
  end

  sig { returns(Integer) }
  def total_registered_booth
    voters.where(origin: "booth").count
  end

  private

    sig { returns(Poll::Voter::PrivateAssociationRelation) }
    def participant_ids
      voters
    end

    sig { returns(Poll::Voter::PrivateAssociationRelation) }
    def voters
      @voters ||= T.let(poll.voters.select(:user_id), T.nilable(Poll::Voter::PrivateAssociationRelation))
    end

    sig { returns(Poll::Recount::PrivateCollectionProxy) }
    def recounts
      @recounts ||= T.let(poll.recounts, T.nilable(Poll::Recount::PrivateCollectionProxy))
    end

    sig { returns(Integer) }
    def total_unregistered_booth
      [total_participants_booth - total_registered_booth, 0].max
    end

    stats_methods.each { |method_name| stats_cache(method_name) }

    sig { params(key: T.any(String, Symbol)).returns(String) }
    def full_cache_key_for(key)
      "polls_stats/#{poll.id}/#{key}"
    end
end
