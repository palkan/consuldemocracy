# typed: strict
module VerificationHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { returns(T::Array[[String, Integer]]) }
  def document_types
    [[t("verification.residence.new.document_type.spanish_id"), 1],
     [t("verification.residence.new.document_type.passport"), 2],
     [t("verification.residence.new.document_type.residence_card"), 3]]
  end

  sig { params(number: String).returns(String) }
  def mask_phone(number)
    match = number.match(/\d{3}$/)
    "******#{match}"
  end

  sig { params(string: String).returns(String) }
  def mask_email(string)
    match = T.must(string.match(/^(\w{1,3})(.*)@(.*)/))

    data_to_display = match[1]
    data_to_mask    = T.must(match[2])
    email_provider  = match[3]

    "#{data_to_display}#{"*" * data_to_mask.size}@#{email_provider}"
  end
end
