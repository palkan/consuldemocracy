# typed: strict
class DuplicateRecordsLogger
  extend T::Sig

  sig { params(message: String).void }
  def info(message)
    logger.info(message)
  end

  sig { returns(ActiveSupport::Logger) }
  def logger
    @logger ||= T.let(ActiveSupport::Logger.new(log_file).tap do |logger|
      logger.formatter = Rails.application.config.log_formatter
    end, T.nilable(ActiveSupport::Logger))
  end

  private

    sig { returns(String) }
    def log_file
      File.join(File.dirname(Rails.application.config.default_log_file), log_filename)
    end

    sig { returns(String) }
    def log_filename
      "duplicate_records.log"
    end
end
