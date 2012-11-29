module ActionView
  module Helpers
    module CacheHelper
       def view_cache(*args, &block)
         options = args.extract_options!
         cache controller.caching_key(options[:tag]), &block
       end
    end
  end
end
