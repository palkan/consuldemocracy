# typed: true

# Devise defines these helpers dynamically for each `devise_for` mapping
# (see config/routes/devise.rb)
module Devise::Controllers::Helpers
  sig { returns(T.nilable(User)) }
  def current_user; end

  sig { returns(T::Boolean) }
  def user_signed_in?; end

  sig { params(opts: T::Hash[Symbol, T.untyped]).void }
  def authenticate_user!(opts = {}); end

  sig { returns(T.untyped) }
  def user_session; end

  sig { returns(T.nilable(User)) }
  def current_organization; end

  sig { returns(T::Boolean) }
  def organization_signed_in?; end

  sig { params(opts: T::Hash[Symbol, T.untyped]).void }
  def authenticate_organization!(opts = {}); end
end

class ActionController::Base
  include Devise::Controllers::Helpers
end

class ActionView::Base
  sig { returns(T.nilable(User)) }
  def current_user; end

  sig { returns(T::Boolean) }
  def user_signed_in?; end
end

# Devise's controllers live in the engine's app/ directory and inherit from
# `Devise.parent_controller`, so they're not part of the gem RBI
class DeviseController < ApplicationController
  sig { returns(T.untyped) }
  def resource; end

  sig { params(new_resource: T.untyped).returns(T.untyped) }
  def resource=(new_resource); end

  sig { returns(Symbol) }
  def resource_name; end

  sig { returns(T.class_of(User)) }
  def resource_class; end

  sig { returns(T.untyped) }
  def signed_in_resource; end

  sig { returns(Devise::Mapping) }
  def devise_mapping; end

  sig { returns(T::Array[Symbol]) }
  def navigational_formats; end

  sig { void }
  def require_no_authentication; end

  sig { params(resource: T.untyped).returns(T::Boolean) }
  def successfully_sent?(resource); end

  sig { params(key: Symbol, kind: T.any(String, Symbol), options: T::Hash[Symbol, T.untyped]).void }
  def set_flash_message(key, kind, options = {}); end

  sig { params(key: Symbol, kind: T.any(String, Symbol), options: T::Hash[Symbol, T.untyped]).void }
  def set_flash_message!(key, kind, options = {}); end

  sig { void }
  def set_minimum_password_length; end

  sig { params(kind: T.any(String, Symbol), options: T::Hash[Symbol, T.untyped]).returns(String) }
  def find_message(kind, options = {}); end

  sig { returns(String) }
  def translation_scope; end

  sig { params(object: T.untyped).void }
  def clean_up_passwords(object); end

  sig { params(args: T.untyped, block: T.untyped).returns(T.untyped) }
  def respond_with_navigational(*args, &block); end

  sig { returns(ActionController::Parameters) }
  def resource_params; end
end

class Devise::RegistrationsController < DeviseController
  def new; end
  def create; end
  def edit; end
  def update; end
  def destroy; end
  def cancel; end

  protected

  sig { params(resource: T.untyped, params: T.untyped).returns(T::Boolean) }
  def update_resource(resource, params); end

  sig { params(hash: T.untyped).returns(T.untyped) }
  def build_resource(hash = {}); end

  sig { params(resource_name: Symbol, resource: T.untyped).void }
  def sign_up(resource_name, resource); end

  sig { params(resource: T.untyped).returns(T.untyped) }
  def after_sign_up_path_for(resource); end

  sig { params(resource: T.untyped).returns(T.untyped) }
  def after_inactive_sign_up_path_for(resource); end

  sig { params(resource: T.untyped).returns(T.untyped) }
  def after_update_path_for(resource); end

  sig { void }
  def authenticate_scope!; end

  sig { returns(ActionController::Parameters) }
  def sign_up_params; end

  sig { returns(ActionController::Parameters) }
  def account_update_params; end
end

class Devise::SessionsController < DeviseController
  def new; end
  def create; end
  def destroy; end

  protected

  sig { returns(ActionController::Parameters) }
  def sign_in_params; end

  sig { returns(T::Hash[Symbol, T.untyped]) }
  def auth_options; end
end

class Devise::ConfirmationsController < DeviseController
  def new; end
  def create; end
  def show; end

  protected

  sig { params(resource_name: Symbol).returns(T.untyped) }
  def after_resending_confirmation_instructions_path_for(resource_name); end

  sig { params(resource_name: Symbol, resource: T.untyped).returns(T.untyped) }
  def after_confirmation_path_for(resource_name, resource); end
end

class Devise::OmniauthCallbacksController < DeviseController
  def passthru; end
  def failure; end

  protected

  sig { returns(T.untyped) }
  def failed_strategy; end

  sig { returns(String) }
  def failure_message; end

  sig { params(scope: Symbol).returns(T.untyped) }
  def after_omniauth_failure_path_for(scope); end
end

# Modules added by the `devise` macro in app/models/user.rb
class User
  include Devise::Models::Authenticatable
  include Devise::Models::DatabaseAuthenticatable
  include Devise::Models::Registerable
  include Devise::Models::Confirmable
  include Devise::Models::Recoverable
  include Devise::Models::Rememberable
  include Devise::Models::Trackable
  include Devise::Models::Validatable
  include Devise::Models::Omniauthable
  include Devise::Models::PasswordExpirable
  include Devise::Models::SecureValidatable
  include Devise::Models::Lockable
  extend Devise::Models::Authenticatable::ClassMethods
  extend Devise::Models::DatabaseAuthenticatable::ClassMethods
  extend Devise::Models::Confirmable::ClassMethods
  extend Devise::Models::Recoverable::ClassMethods
  extend Devise::Models::Rememberable::ClassMethods
  extend Devise::Models::Validatable::ClassMethods
end
