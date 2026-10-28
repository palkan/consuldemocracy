# typed: strict
module WelcomeHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  DebatesList = T.type_alias { T.any(Debate::PrivateRelation, T::Array[Debate]) }
  ProposalsList = T.type_alias { T.any(Proposal::PrivateRelation, T::Array[Proposal]) }

  sig { params(index: Integer).returns(T.nilable(String)) }
  def is_active_class(index)
    "is-active is-in" if index.zero?
  end

  sig { params(index: Integer).returns(T.nilable(String)) }
  def slide_display(index)
    "display: none;" if index.positive?
  end

  sig { params(recommended: T.untyped).returns(T.nilable(ActiveSupport::SafeBuffer)) }
  def render_recommendation_image(recommended)
    image_path = calculate_image_path(recommended)
    image_tag(image_path) if image_path.present?
  end

  # A recommended debate, proposal or investment
  sig { params(recommended: T.untyped).returns(T.untyped) }
  def calculate_image_path(recommended)
    if recommended.respond_to?(:image) && recommended.image.present? &&
       recommended.image.attachment.attached?
      recommended.image.variant(:medium)
    end
  end

  sig { params(debates: DebatesList, proposals: ProposalsList, apply_offset: T::Boolean).returns(String) }
  def calculate_carousel_size(debates, proposals, apply_offset)
    offset = calculate_offset(debates, proposals, apply_offset)
    centered = calculate_centered(debates, proposals)
    "#{offset} #{centered}"
  end

  sig { params(debates: DebatesList, proposals: ProposalsList).returns(T.nilable(String)) }
  def calculate_centered(debates, proposals)
    if (debates.blank? && proposals.any?) ||
       (debates.any? && proposals.blank?)
      "medium-centered large-centered"
    end
  end

  sig do
    params(debates: DebatesList, proposals: ProposalsList,
           apply_offset: T::Boolean).returns(T.nilable(String))
  end
  def calculate_offset(debates, proposals, apply_offset)
    if debates.any? && proposals.any?
      if apply_offset
        "medium-offset-2 large-offset-2"
      else
        "end"
      end
    end
  end
end
