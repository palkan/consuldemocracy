# typed: strict
class Budget::Investment::Exporter
  include CsvExporter
  include JsonExporter
  extend T::Sig

  sig { returns(T::Enumerable[Budget::Investment]) }
  attr_reader :records

  sig { params(investments: T::Enumerable[Budget::Investment]).void }
  def initialize(investments)
    @records = investments
  end

  sig { returns(T.class_of(Budget::Investment)) }
  def model
    Budget::Investment
  end

  private

    sig { returns(T::Array[String]) }
    def model_headers
      [
        I18n.t("admin.budget_investments.index.list.id"),
        I18n.t("admin.budget_investments.index.list.title"),
        I18n.t("admin.budget_investments.index.list.supports"),
        I18n.t("admin.budget_investments.index.list.admin"),
        I18n.t("admin.budget_investments.index.list.valuator"),
        I18n.t("admin.budget_investments.index.list.valuation_group"),
        I18n.t("admin.budget_investments.index.list.geozone"),
        I18n.t("admin.budget_investments.index.list.feasibility"),
        I18n.t("admin.budget_investments.index.list.valuation_finished"),
        I18n.t("admin.budget_investments.index.list.selected"),
        I18n.t("admin.budget_investments.index.list.visible_to_valuators"),
        I18n.t("admin.budget_investments.index.list.author_username"),
        Budget::Investment.human_attribute_name(:created_at)
      ]
    end

    sig { params(investment: Budget::Investment).returns(T::Array[T.nilable(String)]) }
    def record_csv_values(investment)
      [
        investment.id.to_s,
        investment.title,
        investment.total_votes.to_s,
        admin(investment),
        investment.assigned_valuators || "-",
        investment.assigned_valuation_groups || "-",
        T.must(investment.heading).name,
        price(investment),
        investment.valuation_finished? ? I18n.t("shared.yes") : I18n.t("shared.no"),
        investment.selected? ? I18n.t("shared.yes") : I18n.t("shared.no"),
        investment.visible_to_valuators? ? I18n.t("shared.yes") : I18n.t("shared.no"),
        T.must(investment.author).username,
        I18n.l(investment.created_at, format: :datetime)
      ]
    end

    sig { params(investment: Budget::Investment).returns(T.nilable(String)) }
    def admin(investment)
      if (administrator = investment.administrator).present?
        administrator.name
      else
        I18n.t("admin.budget_investments.index.no_admin_assigned")
      end
    end

    sig { params(investment: Budget::Investment).returns(String) }
    def price(investment)
      price_string = "admin.budget_investments.index.feasibility.#{investment.feasibility}"
      if investment.feasible?
        "#{I18n.t(price_string)} (#{investment.formatted_price})"
      else
        I18n.t(price_string)
      end
    end

    sig { params(investment: Budget::Investment).returns(T::Hash[Symbol, T.nilable(T.any(Integer, String))]) }
    def json_values(investment)
      {
        id: investment.id,
        title: investment.title,
        description: strip_tags(investment.description)
      }
    end
end
