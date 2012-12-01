module ActionView
  module Helpers
    module CacheHelper
       def view_cache(*args, &block)
         options = args.extract_options!

         if options[:perform] == false || !controller.perform_caching
           return capture(&block)
         end

         key = controller.caching_key(options[:tag], options[:scope])
         cache(key, expires_in: options[:ttl], &block).tap do
           Interlatch.add_dependencies(key, args)
         end
       end
    end
  end
end
