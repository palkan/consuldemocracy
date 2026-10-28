# typed: true
class Admin::EmailsDownloadController < Admin::BaseController
  sig { void }
  def index
  end

  sig { void }
  def generate_csv
    users_segment = params[:users_segment]
    filename = UserSegments.segment_name(users_segment)

    csv_file = users_segment_emails_csv(users_segment)
    send_data csv_file, filename: "#{filename}.csv"
  end

  private

    sig { params(users_segment: T.nilable(String)).returns(String) }

    def users_segment_emails_csv(users_segment)
      UserSegments.user_segment_emails(users_segment).join(",")
    end
end
