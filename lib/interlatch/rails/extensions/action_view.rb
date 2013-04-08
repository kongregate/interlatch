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
         # doing this more simply fails for some reason
         @output_buffer = @output_buffer.nil? ? clear_link(key) : @output_buffer.to_s + clear_link(key)
       end
       
       def clear_link(key)
         key.sub!(/:[a-zA-Z\-]*$/, ':%25s') # slice off the language
         
         link_to_function("clear key for #{key}", "active_user.deleteCacheKey('#{key}', event)", 
          :class => :caching_link, :style => "color:#22B5BF; display:none", :title => key)
       end
    end
  end
end
