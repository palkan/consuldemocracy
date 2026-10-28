# typed: true
class Management::UserInvitesController < Management::BaseController
  sig { void }
  def new
  end

  sig { void }
  def create
    @emails = params[:emails].split(",").map(&:strip)
    @emails.each do |email|
      Mailer.user_invite(email).deliver_later
    end
  end
end
