# typed: strict
class Shared::RecommendedIndexComponent < ApplicationComponent
  Recommendations = T.type_alias do
    T.nilable(
      T.any(
        Debate::PrivateRelation,
        Debate::PrivateAssociationRelation,
        Proposal::PrivateRelation,
        Proposal::PrivateAssociationRelation
      )
    )
  end

  sig { returns(Recommendations) }
  attr_reader :recommendations

  sig { returns(String) }
  attr_reader :namespace

  delegate :current_path_with_query_params, to: :helpers

  sig { params(recommendations: Recommendations, namespace: String).void }
  def initialize(recommendations, namespace:)
    @recommendations = recommendations
    @namespace = namespace
  end

  sig { returns(T.nilable(T::Boolean)) }
  def render?
    feature?("user.recommendations") && recommendations.present?
  end

  private

    sig { returns(String) }
    def disable_recommendations_path
      if namespace == "debates"
        recommendations_disable_debates_path
      else
        recommendations_disable_proposals_path
      end
    end
end
