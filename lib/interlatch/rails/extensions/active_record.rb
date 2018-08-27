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

        def invalidate_interlatch_caches(instance_only = false)
          return unless Interlatch.tracked_classes.include?(self.class)

          keys = [Interlatch.dependency_key(self)]
          keys <<= Interlatch.dependency_key(self.class) unless instance_only

          ::Rails.cache.read_multi(*keys).values.compact.each do |set|
            set.each { |key| ::Rails.cache.delete(key) }
          end
        end

        def invalidate_interlatch_instance_caches
          invalidate_interlatch_caches(true)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Interlatch::Rails::Extensions::ActiveRecord)
