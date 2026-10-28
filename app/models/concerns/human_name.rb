# typed: strict
module HumanName
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActiveRecord::Base }

  sig { returns(T.untyped) }
  def human_name
    %i[title name subject].each do |method|
      return send(method) if respond_to?(method)
    end

    raise "Must implement a method defining a human name"
  end
end
