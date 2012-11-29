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
end

class InterlatchTest < ActionController::TestCase
  def setup
    @store = ActiveSupport::Cache::MemoryStore.new

    @controller = TestController.new
    @controller.cache_store = @store
  end

  def test_view_cache_with_no_args
    get :no_args, id: '4'

    assert_equal "\nHI\n", @store.fetch('views/interlatch::test:no_args:4:')
  end

  def test_behavior_cache_with_no_args_when_cold
    get :no_args, id: '4'

    assert_equal 'foo', assigns(:foo)
  end

  def test_behavior_cache_with_no_args_when_hot
    @store.write('views/interlatch::test:no_args:4:', 'blah')

    get :no_args, id: '4'

    assert assigns(:foo).nil?
  end

  def test_view_cache_with_tag
    get :with_tag, id: '4'

    assert_equal "\nHI\n", @store.fetch('views/interlatch::test:with_tag:4:tag')
  end

  def test_behavior_cache_with_tag_when_cold
    get :with_tag, id: '4'

    assert_equal 'foo', assigns(:foo)
  end

  def test_behavior_cache_with_tag_when_hot
    @store.write('views/interlatch::test:with_tag:4:tag', 'blah')

    get :with_tag, id: '4'

    assert assigns(:foo).nil?
  end
end
