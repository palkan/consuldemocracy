# typed: strict
class Admin::Proposals::ToggleSelectionComponent < ApplicationComponent
  sig { returns(T.any(Proposal, Legislation::Proposal)) }
  attr_reader :proposal

  sig { params(proposal: T.any(Proposal, Legislation::Proposal)).void }
  def initialize(proposal)
    @proposal = proposal
  end

  private

    sig { returns(Symbol) }
    def action
      if selected?
        :deselect
      else
        :select
      end
    end

    sig { returns(T::Boolean) }
    def selected?
      proposal.selected?
    end

    sig { returns(T::Hash[Symbol, String]) }
    def options
      {
        "aria-label": label
      }
    end

    sig { returns(String) }
    def label
      t("admin.actions.label", action: t("admin.actions.select"), name: proposal.title)
    end
end
