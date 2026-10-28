# typed: strict
class Admin::SignatureSheets::ShowComponent < ApplicationComponent
  sig { returns(SignatureSheet) }
  attr_reader :signature_sheet

  sig { params(signature_sheet: SignatureSheet).void }
  def initialize(signature_sheet)
    @signature_sheet = signature_sheet
  end

  private

    sig { returns(Integer) }
    def voted_signatures
      Vote.where(signature: signature_sheet.signatures.verified).count
    end
end
