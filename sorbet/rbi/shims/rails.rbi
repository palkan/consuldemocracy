# typed: true

# Rails methods that Tapioca's RBIs don't declare, and methods that the
# initializers in config/ add to Rails classes

# Helper methods that controllers expose to views with `helper_method`
# (`dashboard_action` comes from Dashboard::ActionsController and Admin::Dashboard::ActionsController)
class ActionView::Base
  sig { params(action: Symbol, subject: T.untyped, extra_args: T.untyped).returns(T::Boolean) }
  def can?(action, subject, *extra_args); end

  sig { params(action: Symbol, subject: T.untyped, extra_args: T.untyped).returns(T::Boolean) }
  def cannot?(action, subject, *extra_args); end

  sig { returns(Ability) }
  def current_ability; end

  sig { returns(T.nilable(Dashboard::Action)) }
  def dashboard_action; end
end

# Delegated to the attachment (and its blob) with `delegate_missing_to :attachment`
class ActiveStorage::Attached::One
  sig { returns(T::Boolean) }
  def image?; end

  sig { returns(ActiveStorage::Blob) }
  def blob; end

  sig { returns(String) }
  def key; end

  sig { returns(String) }
  def signed_id; end

  sig { returns(ActiveStorage::Filename) }
  def filename; end

  sig { returns(T::Hash[T.untyped, T.untyped]) }
  def metadata; end

  sig { returns(T::Boolean) }
  def analyzed?; end

  sig { void }
  def analyze; end

  sig { params(transformations: T.untyped).returns(T.any(ActiveStorage::Variant, ActiveStorage::VariantWithRecord)) }
  def variant(transformations); end

  sig { returns(T.nilable(String)) }
  def content_type; end

  sig { params(content_type: T.nilable(String)).returns(T.nilable(String)) }
  def content_type=(content_type); end
end

# Defined in config/initializers/routes_hierarchy.rb
module ActionDispatch::Routing::UrlFor
  sig { params(resource: T.untyped, options: T::Hash[Symbol, T.untyped]).returns(String) }
  def management_polymorphic_path(resource, options = {}); end

  sig { params(namespace: T.any(String, Symbol), resource: T.untyped, options: T::Hash[T.untyped, T.untyped]).returns(String) }
  def namespaced_polymorphic_path(namespace, resource, options = {}); end

  sig { params(resource: T.untyped, options: T::Hash[Symbol, T.untyped]).returns(String) }
  def admin_polymorphic_path(resource, options = {}); end
end

# invisible_captcha extends ActionController::Base with its class methods in a Railtie initializer
class ActionController::Base
  extend InvisibleCaptcha::ControllerExt::ClassMethods
end

# caxlsx_rails registers the xlsx MIME type, which defines this collector method
module AbstractController::Collector
  def xlsx(*, **, &); end
end

class ActiveRecord::Relation
  # CanCan::ModelAdditions::ClassMethods#accessible_by, called on relations
  sig { params(ability: CanCan::Ability, action: Symbol, strategy: T.untyped).returns(T.self_type) }
  def accessible_by(ability, action = :index, strategy: nil); end

  # Kaminari defines `page` dynamically (its name is configurable), so Tapioca can't see it
  include Kaminari::PageScopeMethods

  sig { params(num: T.untyped).returns(T.self_type) }
  def page(num = nil); end
end

class ActiveRecord::Base
  # Defined by Kaminari, see ActiveRecord::Relation#page
  class << self
    sig { params(num: T.untyped).returns(T.untyped) }
    def page(num = nil); end
  end

  # devise/orm/active_record adds the `devise` macro
  extend Devise::Models
end

# Class attribute defined by AbstractController::UrlFor/ActionDispatch::Routing::UrlFor
class ActionMailer::Base
  class << self
    sig { returns(T::Hash[Symbol, T.untyped]) }
    def default_url_options; end
  end
end

# Delegated to the wrapped Time through method_missing
class ActiveSupport::TimeWithZone
  sig { returns(ActiveSupport::TimeWithZone) }
  def beginning_of_day; end

  sig { returns(ActiveSupport::TimeWithZone) }
  def end_of_day; end
end

# Defined in config/application.rb
class Rails::Application
  sig { returns(ActiveSupport::OrderedOptions) }
  def secrets; end

  sig { returns(T::Boolean) }
  def multitenancy_management_mode?; end
end
