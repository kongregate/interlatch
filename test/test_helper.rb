require 'minitest/autorun'

require 'rails'
require 'action_controller'

require 'interlatch'

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