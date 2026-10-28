# typed: strict
class SDGManagement::SubnavigationComponent < ApplicationComponent
  sig { returns(Symbol) }
  attr_reader :current

  sig { params(current: Symbol).void }
  def initialize(current:)
    @current = current
  end

  private

    sig { returns(T::Array[Symbol]) }
    def sections
      %i[goals targets local_targets]
    end

    sig { params(section: Symbol).returns(ActiveSupport::SafeBuffer) }
    def link_to_section(section)
      link_to text_for(section), path_for(section), class: active_style(section)
    end

    sig { params(section: Symbol).returns(String) }
    def text_for(section)
      "SDG::#{section.to_s.classify}".constantize.model_name.human(count: 2).titleize
    end

    sig { params(section: Symbol).returns(T::Hash[Symbol, T.any(String, Symbol)]) }
    def path_for(section)
      {
        controller: "sdg_management/#{section}",
        action: :index
      }
    end

    sig { params(section: Symbol).returns(T.nilable(String)) }
    def active_style(section)
      "is-active" if section == current
    end
end
