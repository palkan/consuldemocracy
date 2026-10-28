# typed: true
module MailerHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }
  requires_ancestor { TextWithLinksHelper }

  sig { params(commentable: T.untyped).returns(String) }
  def commentable_url(commentable)
    polymorphic_url(commentable)
  end

  sig { params(commentable: Budget::Investment).returns(String) }
  def valuation_comments_url(commentable)
    admin_budget_budget_investment_url(commentable.budget, commentable, anchor: "comments")
  end

  sig { params(commentable: Budget::Investment).returns(ActiveSupport::SafeBuffer) }
  def valuation_comments_link(commentable)
    link_to(
      commentable.title,
      valuation_comments_url(@email.commentable),
      style: "color: #2895F1; text-decoration:none;"
    )
  end

  sig { params(text: T.nilable(String)).returns(ActiveSupport::SafeBuffer) }
  def mailer_simple_format(text)
    simple_format(sanitize_and_auto_link(text), { style: css_for_mailer_text }, sanitize: false)
  end

  sig { returns(String) }
  def mailer_font_family
    "font-family: 'Open Sans','Helvetica Neue',arial,sans-serif;"
  end

  sig { returns(String) }
  def mailer_footer_spacing
    "margin: 0;padding: 0;line-height: 1.5em;"
  end

  sig { returns(String) }
  def css_for_mailer_heading
    mailer_font_family + "font-size: 48px;"
  end

  sig { returns(String) }
  def css_for_mailer_subheading
    mailer_font_family + "font-size: 20px; font-weight: bold; line-height: 24px; margin-bottom: 2px;"
  end

  sig { returns(String) }
  def css_for_mailer_text
    mailer_font_family + "font-size: 14px;font-weight: normal;line-height: 24px;"
  end

  sig { returns(String) }
  def css_for_mailer_org
    mailer_font_family + mailer_footer_spacing + "color: #797f7f; font-size: 12px;"
  end

  sig { returns(String) }
  def css_for_mailer_footer
    mailer_font_family + mailer_footer_spacing + "color: #222; font-size: 10px; margin-top: 12px;"
  end

  sig { returns(String) }
  def css_for_mailer_button
    mailer_font_family + "background: #004a83;border-radius: 6px;color: #fff!important;" \
                         "display: inline-block;font-weight: bold;margin: 0;" \
                         "min-width: 200px;padding: 10px 15px;text-align: center;" \
                         "text-decoration: none;"
  end

  sig { returns(String) }
  def css_for_mailer_link
    "color: #1779ba; text-decoration: underline;"
  end

  sig { returns(String) }
  def css_for_mailer_quote
    "border-left: 2px solid #DEE0E3;font-style: italic;margin-left: 20px;padding:0px 10px;"
  end

  sig { returns(String) }
  def css_for_mailer_content
    "padding-bottom: 20px; padding-left: 10px;"
  end
end
