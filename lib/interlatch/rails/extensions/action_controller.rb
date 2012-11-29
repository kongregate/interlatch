module ActionController
  class Base
    def caching_key(tag = nil, scope = nil)
      options = { controller: controller_name, action: action_name, id: params[:id], tag: tag }
      if scope == :global
        options.merge! controller: 'any', action: 'any', id: 'any'
      elsif scope == :controller
        options.merge! action: 'any', id: 'any'
      elsif scope == :action
        options.merge! id: 'any'
      end
      Interlatch.caching_key(options[:controller], options[:action], options[:id], options[:tag])
    end

    def behavior_cache(*args, &block)
      options = args.extract_options!

      key = caching_key(options[:tag], options[:scope])
      yield unless fragment_exist? key
    end
  end
end
