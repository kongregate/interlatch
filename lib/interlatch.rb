require "interlatch/version"
require 'interlatch/rails'

module Interlatch
  extend self

  def caching_key(controller, action, id, tag)
    "interlatch:#{ENV['RAILS_ASSET_ID']}:#{controller}:#{action}:#{id}:#{tag}"
  end
end
