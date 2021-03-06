module Interlatch
  module Rails
    module Extensions
      module ActiveRecord
        extend ActiveSupport::Concern

        included do
          after_save :invalidate_interlatch_caches
          after_destroy :invalidate_interlatch_caches
          after_touch :invalidate_interlatch_caches
        end

        def invalidate_interlatch_caches
          self.class.invalidate_interlatch_class_caches
          invalidate_interlatch_instance_caches
        end

        def invalidate_interlatch_instance_caches
          (::Rails.cache.read(Interlatch.dependency_key(self)) || []).each do |key|
            ::Rails.cache.delete(key.dup)
          end
        end

        module ClassMethods
          def invalidate_interlatch_class_caches
            (::Rails.cache.read(Interlatch.dependency_key(self)) || []).each do |key|
              ::Rails.cache.delete(key.dup)
            end
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Interlatch::Rails::Extensions::ActiveRecord)
