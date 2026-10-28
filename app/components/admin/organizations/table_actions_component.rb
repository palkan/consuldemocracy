# typed: strict
class Admin::Organizations::TableActionsComponent < ApplicationComponent
  sig { returns(Organization) }
  attr_reader :organization

  sig { params(organization: Organization).void }
  def initialize(organization)
    @organization = organization
  end

  private

    sig { returns(T::Boolean) }
    def can_verify?
      can? :verify, organization
    end

    sig { returns(T::Boolean) }
    def can_reject?
      can? :reject, organization
    end
end
