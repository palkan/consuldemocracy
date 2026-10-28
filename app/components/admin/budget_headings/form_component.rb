# typed: strict
class Admin::BudgetHeadings::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  sig { returns(Budget::Heading) }
  attr_reader :heading

  sig { returns(String) }
  attr_reader :path

  sig { returns(T.nilable(String)) }
  attr_reader :action

  sig { params(heading: Budget::Heading, path: String, action: T.nilable(String)).void }
  def initialize(heading, path:, action:)
    @heading = heading
    @path = path
    @action = action
  end

  private

    sig { returns(T.nilable(Budget)) }
    def budget
      heading.budget
    end

    sig { returns(T::Boolean) }
    def single_heading?
      helpers.respond_to?(:single_heading?) && helpers.single_heading?
    end

    sig { returns(T::Array[[T.untyped, Integer]]) }
    def geozone_options
      Geozone.all.map { |geozone| [geozone.name, geozone.id] }
    end
end
