require './spec/minitest_helper.rb'
require './lib/asynchronize.rb'

class BasicSpec < Minitest::Test
  describe Asynchronize do
    before do
      class Test
        include Asynchronize
        def test(val=5)
          return val
        end
      end
    end
    after do
      BasicSpec.send(:remove_const, :Test)
    end

    describe "when we asynchronize a method" do
      it "should not be the same method" do
        original_method = Test.instance_method :test
        Test.asynchronize :test
        new_method = Test.instance_method(:test)
        original_method.wont_equal(new_method, "The method was not overwritten")
      end
      it "should not return a thread unless we asynchronize it" do
        Test.new.test.class.wont_equal(Thread, "The method was not overwritten")
      end
      it "should be the same method if we call a second time" do
        Test.asynchronize :test
        original_method = Test.instance_method :test
        Test.asynchronize :test
        new_method = Test.instance_method :test
        original_method.must_equal(new_method,
          "Asynchronized Inception has occurred")
      end
      it "should not throw an error if the specified method does not exist" do
        Test.asynchronize :notamethod
      end
      it "should not create a method if the specified method does not exist" do
        Test.asynchronize :notamethod
        Test.method_defined?(:notamethod).must_equal false
      end
      it "should not affect methods on other classes when called before" do
        Test.asynchronize :test
        class OtherBeforeTest
          def test
          end
        end
        Test.new.test.class.must_equal(Thread)
        OtherBeforeTest.new.test.class.wont_equal(Thread)
      end
      it "should not affect methods on other classes when called after" do
        class OtherAfterTest
          def test
          end
        end
        Test.asynchronize :test
        Test.new.test.class.must_equal(Thread)
        OtherAfterTest.new.test.class.wont_equal(Thread)
      end
    end

    describe "when we call asynchronized after defining the method" do
      before do
        Test.asynchronize :test
      end
      it "should return a thread" do
        Test.new.test.class.must_equal(Thread,
          "The asynchronized method without a block did not return a thread.")
      end
      it "should provide the result in return_value" do
        Test.new.test.join[:return_value].must_equal 5
      end
      it "should provide the result as a block parameter" do
        temp = 0
        Test.new.test do |res|
          temp = res
        end.join
        temp.must_equal 5, "temp is equal to #{temp}."
      end
    end

    describe "when we call asynchronized before defining the method" do
      before do
        class Test
          asynchronize :othertest
          def othertest
            return 5
          end
        end
      end
      it "should return a thread" do
        Test.new.othertest.class.must_equal(Thread,
          "The asynchronized method without a block did not return a thread.")
      end
      it "should provide the result in return_value" do
        Test.new.othertest.join[:return_value].must_equal 5
      end
      it "should provide the result as a block parameter" do
        temp = 0
        Test.new.othertest do |res|
          temp = res
        end.join
        temp.must_equal 5, "temp is equal to #{temp}."
      end
    end

    describe "when there is an existing method_added" do
      before do
        class MethodAddedTest
          @running = false
          def self.method_added(method)
            return if @running
            @running = true
            old_method = instance_method(method)
            undef_method(method)
            define_method(method) do
              return old_method.bind(self).call + 1
            end
            @running = false
          end
          include Asynchronize
          asynchronize :test
          def test
            return 4
          end
        end
      end
      after do
        BasicSpec.send(:remove_const, :MethodAddedTest)
      end
      it "should call that method_added before, and only once." do
        MethodAddedTest.new.test.join[:return_value].must_equal 5
      end
    end

    describe "when inheriting from another class" do
      before do
        class ChildClassTest < Test
          def test
            return super + 1
          end
        end
      end
      it "should be able to call super when it's been asynchronized" do
        class ChildClassTest
          asynchronize :test
        end
        ChildClassTest.new.test.join[:return_value].must_equal 6
      end
    end
  end
end
