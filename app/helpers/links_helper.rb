# typed: strict
module LinksHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(builder: ActionView::Helpers::FormBuilder, element: Link).returns(ActiveSupport::SafeBuffer) }
  def render_destroy_element_link(builder, element)
    link_to_remove_association element.new_record? ? t("links.form.cancel_button") :
                                                     t("links.form.delete_button"),
                               builder, class: "delete remove-element"
  end

  sig { params(options: T::Hash[Symbol, T.untyped]).returns(ActiveSupport::SafeBuffer) }
  def link_to_signin(options = {})
    link_to t("users.signin"), new_user_session_path, options
  end

  sig { params(options: T::Hash[Symbol, T.untyped]).returns(ActiveSupport::SafeBuffer) }
  def link_to_signup(options = {})
    link_to t("users.signup"), new_user_registration_path, options
  end

  sig { returns(ActiveSupport::SafeBuffer) }
  def link_to_verify_account
    link_to t("users.verify_account"), verification_path
  end
end
