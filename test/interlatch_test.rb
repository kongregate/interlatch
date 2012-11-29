require 'test_helper'

class TestController < ActionController::Base
  def no_args
    behavior_cache do
      @foo = 'foo'
    end
  end

  def with_tag
    behavior_cache tag: 'tag' do
      @foo = 'foo'
    end
  end

  def with_global_scope
    behavior_cache tag: 'tag', scope: :global do
      @foo = 'foo'
    end
  end

  def with_controller_scope
    behavior_cache tag: 'tag', scope: :controller do
      @foo = 'foo'
    end
  end

  def with_action_scope
    behavior_cache tag: 'tag', scope: :action do
      @foo = 'foo'
    end
  end
end

class InterlatchTest < ActionController::TestCase
  def setup
    @store = ActiveSupport::Cache::MemoryStore.new

    @controller = TestController.new
    @controller.cache_store = @store
  end

  def test_view_cache_with_no_args
    get :no_args, id: '4'

    assert_equal "\nHI\n", @store.fetch('views/interlatch:8675309:test:no_args:4:')
  end

  def test_behavior_cache_with_no_args_when_cold
    get :no_args, id: '4'

    assert_equal 'foo', assigns(:foo)
  end

  def test_behavior_cache_with_no_args_when_hot
    @store.write('views/interlatch:8675309:test:no_args:4:', 'blah')

    get :no_args, id: '4'

    assert assigns(:foo).nil?
  end

  def test_view_cache_with_tag
    get :with_tag, id: '4'

    assert_equal "\nHI\n", @store.fetch('views/interlatch:8675309:test:with_tag:4:tag')
  end

  def test_behavior_cache_with_tag_when_cold
    get :with_tag, id: '4'

    assert_equal 'foo', assigns(:foo)
  end

  def test_behavior_cache_with_tag_when_hot
    @store.write('views/interlatch:8675309:test:with_tag:4:tag', 'blah')

    get :with_tag, id: '4'

    assert assigns(:foo).nil?
  end

  def test_view_cache_with_ttl
    get :with_ttl, id: '4'

    assert_equal 5.minutes, @store.send(:read_entry, 'views/interlatch:8675309:test:with_ttl:4:', nil).expires_in
  end

  def test_view_cache_with_global_scope
    get :with_global_scope, id: '4'

    assert_equal "\nHI\n", @store.fetch('views/interlatch:8675309:any:any:any:tag')
  end

  def test_behavior_cache_with_global_scope_when_cold
    get :with_global_scope, id: '4'

    assert_equal 'foo', assigns(:foo)
  end

  def test_behavior_cache_with_global_scope_when_hot
    @store.write('views/interlatch:8675309:any:any:any:tag', 'blah')

    get :with_global_scope, id: '4'

    assert assigns(:foo).nil?
  end

  def test_view_cache_with_controller_scope
    get :with_controller_scope, id: '4'

    assert_equal "\nHI\n", @store.fetch('views/interlatch:8675309:test:any:any:tag')
  end

  def test_behavior_cache_with_controller_scope_when_cold
    get :with_controller_scope, id: '4'

    assert_equal 'foo', assigns(:foo)
  end

  def test_behavior_cache_with_controller_scope_when_hot
    @store.write('views/interlatch:8675309:test:any:any:tag', 'blah')

    get :with_controller_scope, id: '4'

    assert assigns(:foo).nil?
  end

  def test_view_cache_with_action_scope
    get :with_action_scope, id: '4'

    assert_equal "\nHI\n", @store.fetch('views/interlatch:8675309:test:with_action_scope:any:tag')
  end

  def test_behavior_cache_with_action_scope_when_cold
    get :with_action_scope, id: '4'

    assert_equal 'foo', assigns(:foo)
  end

  def test_behavior_cache_with_action_scope_when_hot
    @store.write('views/interlatch:8675309:test:with_action_scope:any:tag', 'blah')

    get :with_action_scope, id: '4'

    assert assigns(:foo).nil?
  end
end
