# typed: strict
class Admin::BudgetHeadings::HeadingsComponent < ApplicationComponent
  Headings = T.type_alias do
    T.any(Budget::Heading::PrivateAssociationRelation, Budget::Heading::PrivateCollectionProxy)
  end

  sig { returns(Headings) }
  attr_reader :headings

  sig { params(headings: Headings).void }
  def initialize(headings)
    @headings = headings
    @group = T.let(nil, T.nilable(Budget::Group))
    @budget = T.let(nil, T.nilable(Budget))
  end

  private

    sig { returns(Budget::Group) }
    def group
      @group ||= headings.proxy_association.owner
    end

    sig { returns(T.nilable(Budget)) }
    def budget
      @budget ||= group.budget
    end

    sig { params(heading: Budget::Heading).returns(String) }
    def geozone_for(heading)
      if (geozone = heading.geozone)
        link_to geozone.name, edit_admin_geozone_path(geozone)
      else
        t("geozones.none")
      end
    end
end
