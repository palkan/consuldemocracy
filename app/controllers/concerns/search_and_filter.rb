# typed: true
module SearchAndFilter
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  include Search

  private

    sig do
      params(resources: T.any(Proposal::PrivateRelation, Debate::PrivateRelation))
        .returns(T.any(Proposal::PrivateRelation, Debate::PrivateRelation))
    end
    def search_and_filter(resources)
      user = current_user
      resources = if @current_order == "recommendations" && user.present?
                    resources.recommendations(user)
                  else
                    resources.for_render
                  end
      resources = resources.search(@search_terms) if @search_terms.present?
      resources = resources.filter_by(@advanced_search_terms)

      resources.page(params[:page]).send("sort_by_#{@current_order}")
    end
end
