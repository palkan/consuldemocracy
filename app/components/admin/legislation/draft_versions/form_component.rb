# typed: strict
class Admin::Legislation::DraftVersions::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  sig { returns(Legislation::DraftVersion) }
  attr_reader :draft_version

  sig { returns(String) }
  attr_reader :url

  delegate :admin_submit_action, to: :helpers

  sig { params(draft_version: Legislation::DraftVersion, url: String).void }
  def initialize(draft_version, url:)
    @draft_version = draft_version
    @url = url
  end

  private

    sig { params(attribute: Symbol).returns(String) }
    def attribute_name(attribute)
      Legislation::DraftVersion.human_attribute_name(attribute)
    end

    sig { returns(T.nilable(Legislation::Process)) }
    def process
      draft_version.process
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def form_attributes
      {
        url: url,
        html: {
          data: { markdown_changes_message: markdown_changes_message },
          class: "legislation-draft-versions-form"
        }
      }
    end

    sig { returns(String) }
    def markdown_changes_message
      I18n.t("admin.legislation.draft_versions.edit.markdown_changes_message")
    end

    sig { returns(String) }
    def submit_button_text
      t("admin.legislation.draft_versions.#{admin_submit_action(draft_version)}.submit_button")
    end
end
