# typed: true
module ApplicationHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  # if current path is /debates current_path_with_query_params(foo: "bar") returns /debates?foo=bar
  # notice: if query_params have a param which also exist in current path,
  # it "overrides" (query_params is merged last)
  sig { params(query_parameters: T::Hash[Symbol, T.untyped]).returns(String) }
  def current_path_with_query_params(query_parameters)
    url_for(request.query_parameters.merge(query_parameters).merge(only_path: true))
  end

  sig { params(locale: T.any(String, Symbol)).returns(T::Boolean) }
  def rtl?(locale = T.cast(I18n.locale, Symbol))
    %i[ar fa he].include?(locale)
  end

  sig { params(text: T.nilable(String), render_options: T.untyped).returns(T.nilable(String)) }
  def markdown(text, **render_options)
    MarkdownConverter.new(text, **render_options).render
  end

  sig { params(text: T.nilable(String)).returns(T.nilable(ActiveSupport::SafeBuffer)) }
  def wysiwyg(text)
    WYSIWYGSanitizer.new.sanitize(text)
  end

  sig { void }
  def include_stat_graphs_javascript
    content_for :head do
      javascript_include_tag "stat_graphs", "data-turbolinks-track" => "reload"
    end
  end

  sig { params(authorable: T.untyped, user: T.nilable(User)).returns(T::Boolean) }
  def author_of?(authorable, user)
    return false if authorable.blank? || user.blank?

    authorable.author_id == user.id
  end

  sig { params(destination: T.untyped, text: String).returns(ActiveSupport::SafeBuffer) }
  def back_link_to(destination = :back, text = t("shared.back"))
    link_to destination, class: "back" do
      tag.span(class: "icon-angle-left") + text
    end
  end

  sig { params(text: String, path: T.untyped, options: T.untyped).returns(ActiveSupport::SafeBuffer) }
  def new_window_link_to(text, path, **options)
    link_to text, path, { target: "_blank", title: t("shared.target_blank") }.merge(options)
  end

  sig { params(filename: String).returns(String) }
  def image_path_for(filename)
    image = SiteCustomization::Image.image_for(filename)

    if image
      polymorphic_path(image)
    elsif AssetFinder.find_asset(File.join(Tenant.subfolder_path, filename))
      File.join(Tenant.subfolder_path, filename)
    else
      filename
    end
  end

  sig { params(name: String, locale: T.any(String, Symbol)).returns(T.nilable(String)) }
  def content_block(name, locale = T.cast(I18n.locale, Symbol))
    SiteCustomization::ContentBlock.block_for(name, locale)
  end

  sig { params(path: String).returns(String) }
  def self.asset_data_base64(path)
    asset = (Rails.application.assets || ::Sprockets::Railtie.instance.build_environment(Rails.application))
            .find_asset(path)
    throw "Could not find asset '#{path}'" if asset.nil?
    base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
    "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
  end

  sig { params(partial_name: String).returns(T.nilable(ActiveSupport::SafeBuffer)) }
  def render_custom_partial(partial_name)
    controller_action = @virtual_path.split("/").last
    custom_partial_path = "custom/#{@virtual_path.remove(controller_action)}#{partial_name}"
    render custom_partial_path if lookup_context.exists?(custom_partial_path, [], true)
  end

  sig { returns(T::Boolean) }
  def management_controller?
    controller.class.to_s.include?("Management")
  end
end
