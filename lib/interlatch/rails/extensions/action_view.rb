module ActionView
  module Helpers
    module CacheHelper
       def view_cache(*args, &block)
         options = args.extract_options!
         key = controller.caching_key(options[:tag], options[:scope])
         cache key, expires_in: options[:ttl], &block
         Interlatch.add_dependencies(key, args)
       end
    end
  end
end
