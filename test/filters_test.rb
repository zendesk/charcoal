require File.expand_path('helper', File.dirname(__FILE__))

class FiltersControllerTester < ActionController::Base
  class << self
    include Charcoal::ControllerFilter

    allow :filtering do |method, directive|
      filtering_allowed[method] = directive
    end

    def filtering_allowed
      @filtering_allowed ||= Hash.new(lambda {|_| false })
    end
  end

  def filtering_allowed?
    self.class.filtering_allowed[params[:action].to_sym].call(self)
  end

  def test_action1; true; end
  def test_action2; false; end
end

class FiltersTest < ActiveSupport::TestCase
  context Charcoal::ControllerFilter do
    subject { FiltersControllerTester.new  }
    setup do
      subject.params = {}
    end

    context "controller action filtering" do
      teardown do
        FiltersControllerTester.filtering_allowed.clear
      end

      context "if" do
        context "with a lambda" do
          setup { FiltersControllerTester.allow_filtering :only => :test_action1, :if => lambda {|c| c.test_action1 } }

          should "should allow filtering for test_action1" do
            subject.params.replace(:action => :test_action1)
            assert subject.filtering_allowed?
          end
        end

        context "with a method" do
          setup { FiltersControllerTester.allow_filtering :only => :test_action1, :if => :test_action1 }

          should "should allow filtering for test_action1" do
            subject.params.replace(:action => :test_action1)
            assert subject.filtering_allowed?
          end
        end

        context "with a true/false" do
          setup { FiltersControllerTester.allow_filtering :only => :test_action1, :if => true }

          should "should allow filtering for test_action1" do
            subject.params.replace(:action => :test_action1)
            assert subject.filtering_allowed?
          end
        end
      end

      context "unless" do
        context "with a lambda" do
          setup { FiltersControllerTester.allow_filtering :only => :test_action1, :unless => lambda {|c| c.test_action2 } }

          should "should allow filtering for test_action1" do
            subject.params.replace(:action => :test_action1)
            assert subject.filtering_allowed?
          end
        end

        context "with a method" do
          setup { FiltersControllerTester.allow_filtering :only => :test_action1, :unless => :test_action2 }

          should "should allow filtering for test_action1" do
            subject.params.replace(:action => :test_action1)
            assert subject.filtering_allowed?
          end
        end

        context "with a true/false" do
          setup { FiltersControllerTester.allow_filtering :only => :test_action1, :unless => false }

          should "should allow filtering for test_action1" do
            subject.params.replace(:action => :test_action1)
            assert subject.filtering_allowed?
          end
        end
      end

      context "only" do
        setup { FiltersControllerTester.allow_filtering :only => :test_action1 }

        should "should allow filtering for test_action1" do
          subject.params.replace(:action => :test_action1)
          assert subject.filtering_allowed?
        end

        should "should not allow filtering for test_action2" do
          subject.params.replace(:action => :test_action2)
          assert !subject.filtering_allowed?
        end
      end

      context "except" do
        setup do
          FiltersControllerTester.allow_filtering :except => :test_action2
        end

        should "should allow filtering for test_action1" do
          subject.params.replace(:action => :test_action1)
          assert subject.filtering_allowed?
        end

        should "should not allow filtering for test_action2" do
          subject.params.replace(:action => :test_action2)
          assert !subject.filtering_allowed?
        end
      end

      context "none" do
        setup { FiltersControllerTester.allow_filtering }

        should "should allow filtering for test_action1" do
          subject.params.replace(:action => :test_action1)
          assert subject.filtering_allowed?
        end

        should "should allow filtering for test_action2" do
          subject.params.replace(:action => :test_action1)
          assert subject.filtering_allowed?
        end
      end
    end
  end
end
