# typed: strict
class Tenant < ApplicationRecord
  enum :schema_type, { subdomain: 0, domain: 1 }

  validates :schema,
            presence: true,
            uniqueness: true,
            exclusion: { in: ->(*) { excluded_subdomains }},
            format: { with: URI::DEFAULT_PARSER.regexp[:HOST] }
  validates :name, presence: true, uniqueness: true

  after_create :create_schema
  after_update :rename_schema
  after_destroy :destroy_schema

  scope :only_hidden, -> { where.not(hidden_at: nil) }

  sig { params(host: T.nilable(String)).returns(T.nilable(Tenant)) }
  def self.find_by_domain(host)
    domain.find_by(schema: host)
  end

  sig { params(host: T.nilable(String)).returns(T.nilable(String)) }
  def self.resolve_host(host)
    return nil if Rails.application.config.multitenancy.blank?
    return nil if host.blank? || host.match?(Resolv::AddressRegex)

    schema = schema_for(host)

    if schema && only_hidden.find_by(schema: schema)
      raise Apartment::TenantNotFound
    else
      schema
    end
  end

  sig { params(host: String).returns(T.nilable(String)) }
  def self.schema_for(host)
    host_without_www = host.delete_prefix("www.")

    if find_by_domain(host)
      host
    elsif find_by_domain(host_without_www)
      host_without_www
    else
      host_domain = allowed_domains.find { |domain| host == domain || host.ends_with?(".#{domain}") }
      schema = host_without_www.sub(/\.?#{host_domain}\Z/, "").presence

      if find_by_domain(schema)
        raise Apartment::TenantNotFound
      else
        schema
      end
    end
  end

  sig { returns(T::Array[T.nilable(String)]) }
  def self.allowed_domains
    if Rails.env.local?
      [default_host] + dev_domains
    else
      [default_host]
    end
  end

  sig { returns(T::Array[String]) }
  def self.dev_domains
    %w[localhost lvh.me example.com]
  end

  sig { returns(T::Array[String]) }
  def self.excluded_subdomains
    %w[mail public shared_extensions www]
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def self.default_url_options
    ActionMailer::Base.default_url_options
  end

  sig { returns(T.nilable(String)) }
  def self.default_host
    default_url_options[:host]
  end

  sig { returns(T.nilable(String)) }
  def self.default_domain
    if default_host == "localhost"
      "lvh.me"
    else
      default_host
    end
  end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def self.current_url_options
    default_url_options.merge(host: current_host)
  end

  sig { returns(T.nilable(String)) }
  def self.current_host
    host_for(current_schema)
  end

  sig { params(schema: String).returns(T.nilable(String)) }
  def self.host_for(schema)
    if schema == "public"
      default_host
    elsif find_by_domain(schema)
      schema
    else
      "#{schema}.#{default_domain}"
    end
  end

  # The secrets are read with dynamic accessors (`current_secrets.sms_end_point`)
  sig { returns(T.untyped) }
  def self.current_secrets
    if default?
      Rails.application.secrets
    else
      @secrets ||= T.let({}, T.nilable(T::Hash[String, ActiveSupport::OrderedOptions]))
      @cached_rails_secrets ||= T.let(Rails.application.secrets, T.nilable(ActiveSupport::OrderedOptions))

      if @cached_rails_secrets != Rails.application.secrets
        @secrets = {}
        @cached_rails_secrets = Rails.application.secrets
      end

      @secrets[current_schema] ||= T.cast(
        Rails.application.secrets.merge(Rails.application.secrets.dig(:tenants, current_schema.to_sym).to_h),
        ActiveSupport::OrderedOptions
      )
    end
  end

  sig { returns(String) }
  def self.subfolder_path
    subfolder_path_for(current_schema)
  end

  sig { params(schema: String).returns(String) }
  def self.subfolder_path_for(schema)
    if schema == "public"
      ""
    else
      File.join("tenants", schema)
    end
  end

  sig { params(filename_or_folder: String).returns(String) }
  def self.path_with_subfolder(filename_or_folder)
    File.join(subfolder_path, filename_or_folder).delete_prefix("/")
  end

  sig { returns(T::Boolean) }
  def self.default?
    current_schema == "public"
  end

  sig { returns(String) }
  def self.current_schema
    Apartment::Tenant.current
  end

  sig { returns(T.nilable(Tenant)) }
  def self.current
    find_by(schema: current_schema)
  end

  sig { params(schema: T.nilable(String), block: T.proc.returns(T.untyped)).returns(T.untyped) }
  def self.switch(schema, &block)
    Apartment::Tenant.switch(schema) { block.call }
  end

  sig { params(block: T.proc.void).returns(T::Array[String]) }
  def self.run_on_each(&block)
    ["public"].union(Apartment.tenant_names).each do |schema|
      switch(schema) { block.call }
    end
  end

  sig { returns(T.nilable(String)) }
  def host
    self.class.host_for(T.must(schema))
  end

  sig { returns(T::Boolean) }
  def hide
    update_attribute(:hidden_at, Time.current)
  end

  sig { returns(T::Boolean) }
  def restore
    update_attribute(:hidden_at, nil)
  end

  sig { returns(T::Boolean) }
  def hidden?
    hidden_at.present?
  end

  private

    sig { void }
    def create_schema
      Apartment::Tenant.create(schema)
    end

    sig { void }
    def rename_schema
      if saved_change_to_schema?
        ActiveRecord::Base.connection.execute(
          "ALTER SCHEMA \"#{schema_before_last_save}\" RENAME TO \"#{schema}\";"
        )

        rename_storage
      end
    end

    sig { void }
    def rename_storage
      service = ActiveStorage::Blob.service

      return unless service.respond_to?(:tenant_root_for)

      old_storage = service.tenant_root_for(schema_before_last_save)

      return unless File.directory?(old_storage)

      new_storage = service.tenant_root_for(schema)
      File.rename(old_storage, new_storage)
    end

    sig { void }
    def destroy_schema
      Apartment::Tenant.drop(schema)
    end
end
