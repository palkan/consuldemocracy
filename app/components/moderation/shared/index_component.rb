# typed: strict
class Moderation::Shared::IndexComponent < ApplicationComponent
  include Header

  sig { returns(ActiveRecord::Relation) }
  attr_reader :records

  sig { params(records: ActiveRecord::Relation).void }
  def initialize(records)
    @records = records
  end

  private

    sig { override.returns(String) }
    def title
      t("moderation.#{i18n_namespace}.index.title")
    end

    sig { returns(String) }
    def i18n_namespace
      if table_name == "legislation_proposals"
        "proposals"
      else
        table_name
      end
    end

    sig { returns(String) }
    def form_path
      url_for(
        request.query_parameters.merge(
          controller: "moderation/#{section_name}",
          action: "moderate",
          only_path: true
        )
      )
    end

    sig { returns(String) }
    def table_name
      records.model.table_name
    end

    sig { returns(String) }
    def section_name
      if table_name == "budget_investments"
        "budgets/investments"
      elsif table_name == "legislation_proposals"
        "legislation/proposals"
      else
        table_name
      end
    end
end
