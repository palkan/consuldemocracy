# typed: strict
class AuthenticationLogger
  extend T::Sig

  @loggers = T.let({}, T::Hash[String, T.all(ActiveSupport::Logger, ActiveSupport::TaggedLogging)])

  class << self
    extend T::Sig

    sig { params(message: String).void }
    def log(message)
      logger.tagged(Time.current) do
        logger.info(message)
      end
    end

    sig { returns(Pathname) }
    def path
      Rails.root.join("log", Tenant.subfolder_path, "authentication.log")
    end

    private

      sig { returns(T.all(ActiveSupport::Logger, ActiveSupport::TaggedLogging)) }
      def logger
        @loggers[Apartment::Tenant.current] ||= build_logger
      end

      sig { returns(T.all(ActiveSupport::Logger, ActiveSupport::TaggedLogging)) }
      def build_logger
        FileUtils.mkdir_p(File.dirname(path))
        ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(path, level: :info))
      end
  end
end
