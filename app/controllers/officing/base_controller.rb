# typed: true
class Officing::BaseController < ApplicationController
  layout "admin"
  helper_method :current_booth

  before_action :authenticate_user!
  before_action :verify_officer

  skip_authorization_check

  private

    sig { void }
    def verify_officer
      raise CanCan::AccessDenied unless current_user&.poll_officer?
    end

    sig { void }
    def load_officer_assignment
      @officer_assignments ||= T.must(T.must(current_user).poll_officer)
                               .officer_assignments.where(date: Time.current.to_date)
    end

    sig { void }
    def verify_officer_assignment
      if @officer_assignments.blank?
        redirect_to officing_root_path, notice: t("officing.residence.flash.not_allowed")
      end
    end

    sig { void }
    def verify_booth
      return if current_booth.present?

      booths = T.must(T.must(current_user).poll_officer).todays_booths
      case booths.count
      when 0
        redirect_to officing_root_path
      when 1
        session[:booth_id] = T.must(booths.first).id
      else
        redirect_to new_officing_booth_path
      end
    end

    sig { returns(T.nilable(Poll::Booth)) }
    def current_booth
      Poll::Booth.find_by(id: session[:booth_id])
    end
end
