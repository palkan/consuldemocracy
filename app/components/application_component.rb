# typed: strict
class ApplicationComponent < ViewComponent::Base
  extend T::Sig

  include SettingsHelper

  delegate :back_link_to, :t, :invisible_captcha, :link_to_add_association,
           :link_to_remove_association, :page_entries_info, :paginate, to: :helpers
  delegate :default_form_builder, to: :controller

  sig { params(action: Symbol, subject: T.untyped, extra_args: T.untyped).returns(T::Boolean) }
  def can?(action, subject, *extra_args)
    helpers.can?(action, subject, *extra_args)
  end

  sig { params(action: Symbol, subject: T.untyped, extra_args: T.untyped).returns(T::Boolean) }
  def cannot?(action, subject, *extra_args)
    helpers.cannot?(action, subject, *extra_args)
  end

  sig { returns(T.nilable(User)) }
  def current_user
    helpers.current_user
  end
end
