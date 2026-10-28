# typed: strict
class ApplicationLogger
  extend T::Sig

  sig { params(message: String).void }
  def info(message)
    logger.info(message) unless Rails.env.test?
  end

  sig { params(message: String).void }
  def warn(message)
    logger.warn(message) unless Rails.env.test?
  end

  sig { returns(Logger) }
  def logger
    @logger ||= T.let(Logger.new(STDOUT).tap do |logger|
      logger.formatter = proc { |severity, _datetime, _progname, msg| "#{severity} #{msg}\n" }
    end, T.nilable(Logger))
  end
end
