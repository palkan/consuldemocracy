# typed: strict
class SDG::ProcessEnabled
  extend T::Sig
  include SettingsHelper

  sig { returns(T.any(String, ActiveRecord::Base)) }
  attr_reader :record_or_name

  sig { params(record_or_name: T.any(String, ActiveRecord::Base)).void }
  def initialize(record_or_name)
    @record_or_name = record_or_name
  end

  sig { returns(T.nilable(T::Boolean)) }
  def enabled?
    feature?("sdg") && feature?(process_name) && setting["sdg.process.#{process_name}"] && relatable?
  end

  sig { returns(String) }
  def name
    record_or_name = self.record_or_name

    if record_or_name.is_a?(String)
      record_or_name
    else
      T.must(record_or_name.class.name)
    end
  end

  private

    sig { returns(String) }
    def process_name
      if controller_path_name?
        name.split("/").first
      else
        if module_name == "Legislation"
          "legislation"
        else
          module_name.constantize.table_name
        end
      end
    end

    sig { returns(T::Boolean) }
    def controller_path_name?
      name == name.downcase
    end

    sig { returns(String) }
    def module_name
      T.must(name.split("::").first)
    end

    sig { returns(T::Boolean) }
    def relatable?
      return true if controller_path_name?

      SDG::Related::RELATABLE_TYPES.intersect?([record_or_name.class.name, record_or_name])
    end
end
