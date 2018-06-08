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
      it "should not return a thread unless we asynchronize it" do
        Test.new.test.class.wont_equal(Thread, "The method was not overwritten")
      end
      it "should not throw an error if the specified method does not exist" do
        Test.asynchronize :notamethod
      end
      it "should not create a method if the specified method does not exist" do
        Test.asynchronize :notamethod
        Test.methods(false).wont_include(:notamethod)
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

    describe "when inheriting from another class" do
      before do
        class ChildClassTest < Test
          include Asynchronize
          def test
            return super + 1
          end
        end
      end
      after do
        BasicSpec.send(:remove_const, :ChildClassTest)
      end
      it "should be able to call super when it's been asynchronized" do
        class ChildClassTest
          asynchronize :test
        end
        ChildClassTest.new.test.join[:return_value].must_equal 6
      end
      it "should be able to call super when super has been asynchronized" do
        class Test
          asynchronize :test
        end
        class ChildClassTest
          undef_method :test
          def test
            return super.join[:return_value] + 1
          end
        end
        ChildClassTest.new.test.must_equal 6
      end
    end

    describe "when asynchronize is called" do
      it "should not define an Asynchronized container if there are no arguments" do
        Test.asynchronize
        Test.ancestors.find do |a|
          a.name.split('::').include? 'Asynchronized'
        end.must_be_nil
      end
      it "should not define two modules if we call it twice" do
        Test.asynchronize :test
        Test.asynchronize :another_test
        Test.ancestors.select do |a|
          a.name.split('::').include? 'Asynchronized'
        end.length.must_equal 1
      end
    end
  end
end
