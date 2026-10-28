# typed: strict
class Admin::ActionComponent < ApplicationComponent
  include Admin::Namespace

  sig { returns(Symbol) }
  attr_reader :action

  sig { returns(T.untyped) }
  attr_reader :record

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :options

  sig { params(action: Symbol, record: T.untyped, options: T.untyped).void }
  def initialize(action, record, **options)
    @action = action
    @record = record
    @options = options
  end

  private

    sig { returns(T.nilable(T::Boolean)) }
    def button?
      method && method != :get
    end

    sig { returns(T.untyped) }
    def method
      options[:method] || (:delete if action == :destroy)
    end

    sig { returns(String) }
    def text
      action_key = if action == :destroy
                     :delete
                   else
                     action
                   end

      options[:text] || t("admin.actions.#{action_key}")
    end

    sig { returns(T.untyped) }
    def path
      options[:path] || default_path
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def html_options
      {
        method: method,
        class: html_class,
        id: (dom_id(record, action) if record.respond_to?(:to_key)),
        "aria-describedby": describedby,
        "aria-label": label,
        data: {
          confirm: confirmation_text,
          disable_with: (text if button?)
        }
      }.merge(options.except(:"aria-describedby", :"aria-label", :class, :confirm, :method, :path, :text))
    end

    sig { returns(String) }
    def html_class
      "admin-action #{options[:class] || "#{action.to_s.gsub("_", "-")}-link"}".strip
    end

    sig { returns(T.untyped) }
    def describedby
      if options[:"aria-describedby"] == true
        "#{dom_id(record, action)}_descriptor"
      else
        options[:"aria-describedby"]
      end
    end

    sig { returns(T.untyped) }
    def label
      if options[:"aria-label"] == true
        t("admin.actions.label", action: text, name: record_name)
      else
        options[:"aria-label"]
      end
    end

    sig { returns(T.untyped) }
    def confirmation_text
      if options[:confirm] == true
        if action == :destroy
          t("admin.actions.confirm_delete", name: record_name)
        else
          t("admin.actions.confirm_action", action: text, name: record_name)
        end
      elsif options[:confirm].respond_to?(:call)
        options[:confirm].call(record_name)
      else
        options[:confirm]
      end
    end

    sig { returns(T.nilable(String)) }
    def record_name
      if record.respond_to?(:human_name)
        record.human_name
      else
        record.to_s.humanize
      end
    end

    sig { returns(String) }
    def default_path
      if %i[configure destroy options preview show].include?(action.to_sym)
        namespaced_polymorphic_path(namespace, record)
      else
        namespaced_polymorphic_path(namespace, record, { action: action }.merge(request.query_parameters))
      end
    end
end
