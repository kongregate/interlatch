require 'minitest/autorun'

require 'rails'
require 'action_controller'
require 'active_record'

require 'interlatch'

ENV['RAILS_ASSET_ID'] = '8675309'

SHARED_TEST_ROUTES = ActionDispatch::Routing::RouteSet.new
SHARED_TEST_ROUTES.draw do
  match ':controller(/:action(/:id))'
end

TEMPLATE_PATH = File.join(File.dirname(__FILE__), 'templates')

module ActionController
  class Base
    include SHARED_TEST_ROUTES.url_helpers
  end
  Base.view_paths = TEMPLATE_PATH

  class TestCase
    setup do
      @routes = SHARED_TEST_ROUTES
    end
  end
end

ActiveRecord::Base.configurations = {
  'test' =>  {
    'adapter' => 'sqlite3',
    'database' => ':memory:'
  }
}
