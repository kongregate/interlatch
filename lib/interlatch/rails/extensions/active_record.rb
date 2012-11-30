module Interlatch
  module Rails
    module Extensions
      module ActiveRecord
        extend ActiveSupport::Concern

        included do
          after_save :invalidate_caches
          after_destroy :invalidate_caches
        end

        def invalidate_caches
          (::Rails.cache.fetch(Interlatch.dependency_key(self.class)) || []).each do |key|
            ::Rails.cache.delete(key)
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Interlatch::Rails::Extensions::ActiveRecord)
