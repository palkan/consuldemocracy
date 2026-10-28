# typed: strict
class Admin::HiddenTableActionsComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :record

  sig { params(record: T.untyped).void }
  def initialize(record)
    @record = record
  end

  private

    sig { returns(String) }
    def restore_text
      t("admin.actions.restore")
    end

    sig { returns(String) }
    def restore_path
      action_path(:restore)
    end

    sig { returns(String) }
    def confirm_hide_text
      t("admin.actions.confirm_hide")
    end

    sig { returns(String) }
    def confirm_hide_path
      action_path(:confirm_hide)
    end

    sig { params(action: Symbol).returns(String) }
    def action_path(action)
      url_for({
        controller: "admin/hidden_#{record.model_name.plural}",
        action: action,
        id: record,
        only_path: true
      }.merge(request.query_parameters))
    end
end
