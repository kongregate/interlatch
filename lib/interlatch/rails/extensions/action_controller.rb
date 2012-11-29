module ActionController
  class Base
    def caching_key(tag = nil)
      Interlatch.caching_key(controller_name, action_name, params[:id], tag)
    end

    def behavior_cache(*args, &block)
      options = args.extract_options!

      key = caching_key(options[:tag])
      yield unless fragment_exist? key
    end
  end
end
