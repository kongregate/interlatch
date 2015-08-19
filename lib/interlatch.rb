require 'interlatch/version'
require 'interlatch/rails'

module Interlatch
  extend self

  def caching_key(controller, action, id, tag, locale)
    cache_version = cache_version_hook ? cache_version_hook.call : nil

    [
      'interlatch',
      ENV['RAILS_ASSET_ID'],
      controller,
      action,
      id || 'all',
      tag || 'untagged',
      locale,
      cache_version
    ].compact.join(':')
  end

  def dependency_key(dependency)
    dependency_str = dependency.kind_of?(Class) ? dependency.to_s : "#{dependency.class.name}:#{dependency.id}"
    "interlatch:#{dependency_str}"
  end

  def add_dependencies(key, dependencies)
    dependencies.each do |dependency|
      dep_key = dependency_key(dependency)
      dependency_cache = ::Rails.cache.read(dep_key).try(:dup) || Set.new
      dependency_cache << "views/#{key}"
      ::Rails.cache.write(dep_key, dependency_cache)
    end
  end

  mattr_accessor :locale_method, :cache_version_hook
end
