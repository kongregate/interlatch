require 'test_helper'

ActiveRecord::Base.establish_connection 'test'
class Foo < ActiveRecord::Base
end
Foo.connection.create_table(:foos)

class Bar < ActiveRecord::Base
end
Bar.connection.create_table(:bars)

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

  def with_one_dependency
    behavior_cache Foo do
      @foo = 'foo'
    end
  end

  def with_two_dependencies
    behavior_cache Foo, Bar do
      @foo = 'foo'
    end
  end

  def model_instance_as_dependency
    behavior_cache Foo.find(params[:foo_id]) do
      @foo
    end
  end

  def perform
    behavior_cache perform: false do
      @foo = 'foo'
    end
  end

  private
  def current_locale
    'en_us'
  end
end

class InterlatchTest < ActionController::TestCase
  def setup
    @store = ActiveSupport::Cache::MemoryStore.new

    @controller = TestController.new
    @controller.cache_store = @store
    silence_warnings { Object.const_set "RAILS_CACHE", @store }
  end

  def test_view_cache_with_no_args
    get :no_args, id: '4'

    assert_equal "\nHI\n", @store.read('views/interlatch:8675309:test:no_args:4:untagged')
  end

  def test_behavior_cache_with_no_args_when_cold
    get :no_args, id: '4'

    assert_equal 'foo', assigns(:foo)
  end

  def test_behavior_cache_with_no_args_when_hot
    @store.write('views/interlatch:8675309:test:no_args:4:untagged', 'blah')

    get :no_args, id: '4'

    assert_nil assigns(:foo)
  end

  def test_view_cache_with_tag
    get :with_tag, id: '4'

    assert_equal "\nHI\n", @store.read('views/interlatch:8675309:test:with_tag:4:tag')
  end

  def test_behavior_cache_with_tag_when_cold
    get :with_tag, id: '4'

    assert_equal 'foo', assigns(:foo)
  end

  def test_behavior_cache_with_tag_when_hot
    @store.write('views/interlatch:8675309:test:with_tag:4:tag', 'blah')

    get :with_tag, id: '4'

    assert_nil assigns(:foo)
  end

  def test_view_cache_with_ttl
    get :with_ttl, id: '4'

    assert_equal 5.minutes, @store.send(:read_entry, 'views/interlatch:8675309:test:with_ttl:4:untagged', nil).expires_in
  end

  def test_view_cache_with_global_scope
    get :with_global_scope, id: '4'

    assert_equal "\nHI\n", @store.read('views/interlatch:8675309:any:any:any:tag')
  end

  def test_behavior_cache_with_global_scope_when_cold
    get :with_global_scope, id: '4'

    assert_equal 'foo', assigns(:foo)
  end

  def test_behavior_cache_with_global_scope_when_hot
    @store.write('views/interlatch:8675309:any:any:any:tag', 'blah')

    get :with_global_scope, id: '4'

    assert_nil assigns(:foo)
  end

  def test_view_cache_with_controller_scope
    get :with_controller_scope, id: '4'

    assert_equal "\nHI\n", @store.read('views/interlatch:8675309:test:any:any:tag')
  end

  def test_behavior_cache_with_controller_scope_when_cold
    get :with_controller_scope, id: '4'

    assert_equal 'foo', assigns(:foo)
  end

  def test_behavior_cache_with_controller_scope_when_hot
    @store.write('views/interlatch:8675309:test:any:any:tag', 'blah')

    get :with_controller_scope, id: '4'

    assert_nil assigns(:foo)
  end

  def test_view_cache_with_action_scope
    get :with_action_scope, id: '4'

    assert_equal "\nHI\n", @store.read('views/interlatch:8675309:test:with_action_scope:any:tag')
  end

  def test_behavior_cache_with_action_scope_when_cold
    get :with_action_scope, id: '4'

    assert_equal 'foo', assigns(:foo)
  end

  def test_behavior_cache_with_action_scope_when_hot
    @store.write('views/interlatch:8675309:test:with_action_scope:any:tag', 'blah')

    get :with_action_scope, id: '4'

    assert_nil assigns(:foo)
  end

  def test_behavior_cache_with_one_dependency
    get :with_one_dependency, id: '4'

    assert_equal ['views/interlatch:8675309:test:with_one_dependency:4:untagged'], @store.read('interlatch:Foo').to_a
  end

  def test_behavior_cache_with_two_dependencies
    get :with_two_dependencies, id: '4'

    assert_equal ['views/interlatch:8675309:test:with_two_dependencies:4:untagged'], @store.read('interlatch:Foo').to_a
    assert_equal ['views/interlatch:8675309:test:with_two_dependencies:4:untagged'], @store.read('interlatch:Bar').to_a
  end

  def test_dependency_with_multiple_view_caches
    @store.write('interlatch:Foo', Set.new(['blah']))

    get :with_one_dependency, id: '4'

    assert_equal ['blah', 'views/interlatch:8675309:test:with_one_dependency:4:untagged'], @store.read('interlatch:Foo').to_a
  end

  def test_create_invalidates_cache
    @store.write('interlatch:Foo', ['blah'])
    @store.write('blah', 'blah')

    Foo.create

    assert_nil @store.read('blah')
  end

  def test_destroy_invalidates_cache
    f = Foo.create
    @store.write('interlatch:Foo', ['blah'])
    @store.write('blah', 'blah')

    f.destroy

    assert_nil @store.read('blah')
  end

  def test_null_id_is_all
    get :no_args

    assert_equal "\nHI\n", @store.read('views/interlatch:8675309:test:no_args:all:untagged')
  end

  def test_locale
    begin
      Interlatch.locale_method = :current_locale

      get :no_args, id: '4'

      assert_equal "\nHI\n", @store.read('views/interlatch:8675309:test:no_args:4:untagged:en_us')
    ensure
      Interlatch.locale_method = nil
    end
  end

  def test_view_cache_with_dependency
    get :view_cache_with_dependency

    assert_equal ['views/interlatch:8675309:test:view_cache_with_dependency:all:untagged'], @store.read('interlatch:Foo').to_a
  end

  def test_model_instance_as_dependency
    foo = Foo.create

    get :model_instance_as_dependency, foo_id: foo.id

    assert_equal ['views/interlatch:8675309:test:model_instance_as_dependency:all:untagged'], @store.read("interlatch:Foo:#{foo.id}").to_a
  end

  def test_model_instance_as_dependency_invalidates_on_save
    foo = Foo.create
    get :model_instance_as_dependency, foo_id: foo.id

    foo.save

    assert_nil @store.read('views/interlatch:8675309:test:model_instance_as_dependency:all:untagged')
  end

  def test_model_instance_as_dependency_invalidates_on_touch
    foo = Foo.create
    get :model_instance_as_dependency, foo_id: foo.id

    foo.touch

    assert_nil @store.read('views/interlatch:8675309:test:model_instance_as_dependency:all:untagged')
  end

  def test_model_instance_as_dependency_invalidates_on_destroy
    foo = Foo.create
    get :model_instance_as_dependency, foo_id: foo.id

    foo.destroy

    assert_nil @store.read('views/interlatch:8675309:test:model_instance_as_dependency:all:untagged')
  end

  def test_no_caching_doesnt_cache
    @controller.perform_caching = false

    get :no_args, id: '4'

    assert_nil @store.read('views/interlatch:8675309:test:no_args:4:untagged')
  end

  def test_no_caching_always_runs_behavior
    @controller.perform_caching = false
    @store.write('views/interlatch:8675309:test:no_args:4:untagged', 'foo')

    get :no_args, id: '4'

    assert_equal 'foo', assigns(:foo)
  end

  def test_perform_false_doesnt_cache
    get :perform

    assert_nil @store.read('views/interlatch:8675309:test:perform:all:untagged')
  end

  def test_perform_false_always_runs_behavior
    @store.write('views/interlatch:8675309:test:perform:all:untagged', 'foo')

    get :perform

    assert_equal 'foo', assigns(:foo)
  end
end
