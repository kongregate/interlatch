module ActionView
  module Helpers
    module CacheHelper
       def view_cache(*args, &block)
         options = args.extract_options!
         options.assert_valid_keys(:perform, :scope, :tag, :ttl)

         if options[:perform] == false || !controller.perform_caching
           return capture(&block)
         end

         key = controller.caching_key(options[:tag], options[:scope])
         Interlatch.add_dependencies(key, args)
         cache(key, expires_in: options[:ttl], &block)
       end
    end
  end
end
