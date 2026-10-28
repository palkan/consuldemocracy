# typed: true
class DeviseMailer < Devise::Mailer
  extend T::Sig

  include Devise::Controllers::UrlHelpers

  default template_path: "devise/mailer"

  protected

    sig { params(record: User, action: Symbol, opts: T::Hash[Symbol, T.untyped]).returns(Mail::Message) }
    def devise_mail(record, action, opts = {})
      I18n.with_locale(record.locale) { super }
    end
end
