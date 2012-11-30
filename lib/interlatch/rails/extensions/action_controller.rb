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
      locale = Interlatch.locale_method ? self.send(Interlatch.locale_method) : nil

      Interlatch.caching_key(options[:controller], options[:action], options[:id], options[:tag], locale)
    end

    def behavior_cache(*args, &block)
      options = args.extract_options!

      key = caching_key(options[:tag], options[:scope])
      unless fragment_exist? key
        yield
        args.each do |dependency|
          add_dependency(key, dependency.to_s)
        end
      end
    end

    def add_dependency(key, dependency)
      dependency_cache = cache_store.fetch("interlatch:#{dependency}").try(:dup) || Set.new
      dependency_cache << "views/#{key}"
      cache_store.write("interlatch:#{dependency}", dependency_cache)
    end
  end
end
