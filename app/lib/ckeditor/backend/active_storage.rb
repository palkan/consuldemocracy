# typed: strict
# frozen_string_literal: true

# Code copied from the ckeditor gem:
# https://github.com/galetahub/ckeditor/pull/853
module Ckeditor
  module Backend
    module ActiveStorage
      extend T::Sig

      sig { params(base: T.class_of(Ckeditor::Asset)).void }
      def self.included(base)
        base.send(:include, Rails.application.routes.url_helpers)
        base.send(:include, InstanceMethods)
        base.send(:extend, ClassMethods)
      end

      module ClassMethods
        extend T::Sig

        sig { params(base: T.class_of(Ckeditor::Asset)).void }
        def self.extended(base)
          base.class_eval do
            before_validation :apply_data
            validate do
              T.bind(self, T.all(Ckeditor::Picture, InstanceMethods))

              if data.nil? || file.nil?
                errors.add(:data, :not_data_present, message: "data must be present")
              end
            end
          end
        end
      end

      # Ckeditor::Picture is the only kind of asset in this application
      module InstanceMethods
        extend T::Sig
        extend T::Helpers

        requires_ancestor { Ckeditor::Picture }
        requires_ancestor { GeneratedPathHelpersModule }

        sig { returns(String) }
        def url
          rails_blob_path(self.storage_data, only_path: true)
        end

        sig { returns(String) }
        def path
          rails_blob_path(self.storage_data, only_path: true)
        end

        sig { returns(NilClass) }
        def styles
        end

        sig { returns(T.nilable(String)) }
        def content_type
          self.storage_data.content_type
        end

        sig { params(_content_type: T.nilable(String)).void }
        def content_type=(_content_type)
          self.storage_data.content_type = _content_type
        end

        protected

          sig { returns(::ActiveStorage::Attached::One) }
          def file
            @file ||= T.let(storage_data, T.nilable(::ActiveStorage::Attached::One))
          end

          sig { returns(::ActiveStorage::Blob) }
          def blob
            @blob ||= T.let(
              ::ActiveStorage::Blob.find(file.attachment.blob_id),
              T.nilable(::ActiveStorage::Blob)
            )
          end

          sig { void }
          def apply_data
            if data.is_a?(Ckeditor::Http::QqFile)
              storage_data.attach(io: data, filename: data.original_filename)
            else
              storage_data.attach(data)
            end

            self.data_file_name = storage_data.blob.filename
            self.data_content_type = storage_data.blob.content_type
            self.data_file_size = storage_data.blob.byte_size
          end
      end
    end
  end
end
