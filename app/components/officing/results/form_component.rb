# typed: strict
class Officing::Results::FormComponent < ApplicationComponent
  sig { returns(Poll) }
  attr_reader :poll

  sig { returns(Poll::OfficerAssignment::PrivateRelation) }
  attr_reader :officer_assignments

  delegate :booths_for_officer_select_options, to: :helpers

  sig { params(poll: Poll, officer_assignments: Poll::OfficerAssignment::PrivateRelation).void }
  def initialize(poll, officer_assignments)
    @poll = poll
    @officer_assignments = officer_assignments
  end

  private

    sig { params(question_id: Integer, option_id: Integer).returns(Integer) }
    def answer_result_value(question_id, option_id)
      params.dig(:questions, question_id.to_s, option_id.to_s).to_i
    end
end
