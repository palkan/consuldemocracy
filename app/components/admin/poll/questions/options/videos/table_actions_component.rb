# typed: strict
class Admin::Poll::Questions::Options::Videos::TableActionsComponent < ApplicationComponent
  sig { returns(::Poll::Question::Option::Video) }
  attr_reader :video

  sig { params(video: ::Poll::Question::Option::Video).void }
  def initialize(video)
    @video = video
  end
end
