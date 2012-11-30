require "interlatch/version"
require 'interlatch/rails'

module Interlatch
  extend self

  def caching_key(controller, action, id, tag, locale)
    parts = [
      "interlatch",
      ENV['RAILS_ASSET_ID'],
      controller,
      action,
      id || 'all',
      tag || 'untagged',
      locale
    ].compact.join(":")
  end

  def dependency_key(dependency_class)
    "interlatch:#{dependency_class.to_s}"
  end

  mattr_accessor :locale_method
end
