# typed: true
class Dashboard::Mailer < ApplicationMailer
  layout "mailer"
  after_action :check_deliverability, except: [:forward]

  sig { params(proposal: Proposal).void }
  def forward(proposal)
    @proposal = proposal
    mail to: T.must(proposal.author).email, subject: proposal.title
  end

  sig { params(proposal: Proposal).void }
  def new_actions_notification_on_create(proposal)
    @proposal = proposal
    mail to: T.must(proposal.author).email,
         subject: I18n.t("mailers.new_actions_notification_on_create.subject")
  end

  sig { params(proposal: Proposal, new_actions_ids: T::Array[Integer]).void }
  def new_actions_notification_on_published(proposal, new_actions_ids)
    @proposal = proposal
    @new_actions = get_new_actions(new_actions_ids)
    mail to: T.must(proposal.author).email,
         subject: I18n.t("mailers.new_actions_notification_on_published.subject")
  end

  private

    sig { params(new_actions_ids: T::Array[Integer]).returns(Dashboard::Action::PrivateRelation) }
    def get_new_actions(new_actions_ids)
      Dashboard::Action.where(id: new_actions_ids)
    end

    sig { void }
    def check_deliverability
      mail.perform_deliveries = false unless Setting["feature.dashboard.notification_emails"]
    end
end
