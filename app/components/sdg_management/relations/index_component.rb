# typed: strict
class SDGManagement::Relations::IndexComponent < ApplicationComponent
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
      t("sdg_management.menu.#{model_class.table_name}")
    end

    sig { returns(T.class_of(ActiveRecord::Base)) }
    def model_class
      records.model
    end

    sig { params(record: T.untyped).returns(T::Hash[Symbol, T.untyped]) }
    def edit_path_for(record)
      {
        controller: "sdg_management/relations",
        action: :edit,
        relatable_type: record.class.name.tableize,
        id: record
      }
    end

    sig { returns(String) }
    def search_label
      t("admin.shared.search.label.#{model_class.table_name}")
    end
end
