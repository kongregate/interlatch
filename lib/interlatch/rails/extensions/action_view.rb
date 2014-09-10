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
         cache(key, expires_in: options[:ttl], skip_digest: true, &block)
         clear_link = clear_caching_link("views/#{key}")
         (@output_buffer = @output_buffer.nil? ? clear_link : @output_buffer.to_s + clear_link) if clear_link
       end

       def clear_caching_link(key, css_class = 'clear_caching_link', text = nil)
         return unless Interlatch.add_clear_caching_links
         text ||= "clear key for #{key}"
         link_to text, "#", "data-key" => key, :class => css_class, :title => key, :style => "display:none"
       end
    end
  end
end
