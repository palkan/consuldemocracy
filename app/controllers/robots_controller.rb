# typed: strict
class RobotsController < ApplicationController
  skip_authorization_check

  sig { void }
  def index
    respond_to :text
  end
end
