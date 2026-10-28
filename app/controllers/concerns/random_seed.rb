# typed: strict
module RandomSeed
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  sig { void }
  def set_random_seed
    seed = (params[:random_seed] || session[:random_seed] || rand(10_000_000)).to_i

    session[:random_seed] = seed
    params[:random_seed] = seed
  end
end
