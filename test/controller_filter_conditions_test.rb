require "minitest/autorun"
require "open3"
require "rbconfig"
require "active_support"
require "charcoal/controller_filter"

class ControllerFilterConditionsTest < Minitest::Test
  def setup
    @controller_class = Class.new do
      class << self
        include Charcoal::ControllerFilter

        def permissions
          @permissions ||= Hash.new(lambda { |_| false })
        end

        allow :testing do |action, directive|
          permissions[action] = directive
        end
      end

      private

      def permitted?
        true
      end

      def blocked?
        false
      end
    end
    @controller = @controller_class.new
  end

  def test_private_symbol_predicates
    @controller_class.allow_testing :index, if: :permitted?, unless: :blocked?
    assert allowed?

    @controller_class.allow_testing :index, if: :blocked?
    refute allowed?

    @controller_class.allow_testing :index, unless: :permitted?
    refute allowed?
  end

  def test_predicates_defined_after_registration
    @controller_class.allow_testing :index, if: :defined_later?
    @controller_class.class_eval do
      private

      def defined_later?
        false
      end
    end
    refute allowed?
  end

  def test_missing_predicates_raise_instead_of_granting_permission
    @controller_class.allow_testing :index, if: :missing?
    assert_raises(NoMethodError) { allowed? }
  end

  def test_zero_argument_blocks_use_the_controller_context
    @controller_class.allow_testing :index, if: -> { permitted? }, unless: -> { blocked? }
    assert allowed?
  end

  def test_one_argument_blocks_receive_the_controller_and_use_its_context
    instance = @controller
    @controller_class.allow_testing :index, if: ->(controller) { controller.equal?(instance) && permitted? }
    assert allowed?
  end

  def test_one_argument_procs_can_call_private_predicates
    @controller_class.allow_testing :index, if: proc { |controller| controller.send(:permitted?) }
    assert allowed?
  end

  def test_lambdas_with_optional_keywords_receive_the_controller
    instance = @controller
    @controller_class.allow_testing :index, if: ->(controller, role: "admin") { controller.equal?(instance) && role == "admin" && permitted? }
    assert allowed?
  end

  def test_lambdas_with_optional_positional_arguments_receive_the_controller
    instance = @controller
    @controller_class.allow_testing :index, if: ->(controller = nil) { controller.equal?(instance) && permitted? }
    assert allowed?
  end

  def test_procs_with_splats_receive_the_controller
    instance = @controller
    @controller_class.allow_testing :index, if: proc { |*arguments| arguments == [instance] && permitted? }
    assert allowed?
  end

  def test_keyword_only_lambdas_do_not_receive_a_positional_argument
    @controller_class.allow_testing :index, if: ->(role: "admin") { role == "admin" && permitted? }
    assert allowed?
  end

  def test_standalone_loading_includes_the_required_core_extensions
    code = <<~RUBY
      require "charcoal/controller_filter"

      class Controller
        class << self
          include Charcoal::ControllerFilter
          attr_reader :directive

          allow :testing do |action, directive|
            @directive = directive
          end
        end
      end

      Controller.allow_testing :index, if: true
      abort "permission was not granted" unless Controller.directive.call(Controller.new)
    RUBY
    output, status = Open3.capture2e(RbConfig.ruby, "-I", File.expand_path("../lib", __dir__), "-e", code)
    assert status.success?, output
  end

  def test_if_and_unless_both_apply
    @controller_class.allow_testing :index, if: false, unless: false
    refute allowed?

    @controller_class.allow_testing :index, if: true, unless: true
    refute allowed?
  end

  def test_arrays_require_every_if_and_no_unless_condition_to_pass
    @controller_class.allow_testing :index, if: [:permitted?, -> { true }], unless: [:blocked?, -> { false }]
    assert allowed?

    @controller_class.allow_testing :index, if: [:permitted?, -> { false }]
    refute allowed?

    @controller_class.allow_testing :index, unless: [:blocked?, -> { true }]
    refute allowed?
  end

  def test_conditions_short_circuit
    @controller_class.allow_testing :index, if: [false, -> { raise "should not run" }], unless: -> { raise "should not run" }
    refute allowed?

    @controller_class.allow_testing :index, unless: [true, -> { raise "should not run" }]
    refute allowed?
  end

  def test_boolean_conditions
    @controller_class.allow_testing :index, if: false
    refute allowed?

    @controller_class.allow_testing :index, unless: false
    assert allowed?

    @controller_class.allow_testing :index, if: true
    assert allowed?

    @controller_class.allow_testing :index, unless: true
    refute allowed?
  end

  def test_callable_objects_keep_receiving_the_controller
    instance = @controller
    condition = Object.new
    condition.define_singleton_method(:call) { |controller| controller.equal?(instance) }
    @controller_class.allow_testing :index, if: condition
    assert allowed?
  end

  def test_conditions_are_evaluated_on_each_call
    permitted = true
    @controller_class.allow_testing :index, if: -> { permitted }
    assert allowed?
    permitted = false
    refute allowed?
  end

  def test_string_method_names_remain_supported
    @controller_class.allow_testing :index, if: "blocked?"
    refute allowed?
  end

  def test_registration_preserves_action_keys_and_callable_directives
    @controller_class.allow_testing "index", :show
    assert_equal [:index, :show], @controller_class.permissions.keys
    assert allowed?
    assert allowed?(:show)
    refute allowed?(:other)

    @controller_class.allow_testing :index, if: false
    refute allowed?
    assert allowed?(:show)
  end

  def test_no_actions_registers_all
    @controller_class.allow_testing
    assert_equal [:all], @controller_class.permissions.keys
    assert allowed?(:all)
  end

  def test_permissions_do_not_inherit
    @controller_class.allow_testing
    subclass = Class.new(@controller_class)
    assert_empty subclass.permissions
    refute subclass.permissions[:all].call(subclass.new)
  end

  private

  def allowed?(action = :index)
    @controller_class.permissions[action].call(@controller)
  end
end
