module Asynchronize
  require 'set'
  def self.included base
    base.class_eval do
      # The methods we have already asynchronized
      @@asynced_methods = Set.new
      # The methods that should be asynchronized.
      @@methods_to_async = Set.new
      # Originally used a single value here, but that's not thread safe.
      # ...Though you probably have other problems if you have multiple
      # threads adding methods to your class.
      @@methods_asyncing = Set.new

      def self.asynchronize(*methods)
        @@methods_to_async.merge(methods)
        methods.each do |method|
          # If it's not defined yet, we'll get it with method_added
          next unless method_defined? method
          Asynchronize.create_new_method(method, self)
        end
      end

      # Save the old method_added so we don't overwrite it.
      @@old_method_added = nil
      if method_defined? "method_added"
        @@old_method_added = instance_method(:method_added)
        undef_method(:method_added)
      end

      def self.method_added(method)
        @@old_method_added.bind(self).(method) unless @@old_method_added.nil?
        return unless @@methods_to_async.include? method
        return if @@methods_asyncing.include? method
        Asynchronize.create_new_method(method, self)
      end
    end
  end

  def self.create_new_method(method, klass)
    klass.instance_eval do
      old_method = instance_method(method)
      return if @@asynced_methods.include?(old_method)
      undef_method method
      @@methods_asyncing.add(method)

      define_method(method) do |*args, &block|
        return Thread.new(args, block) do |targs, tblock|
          result = old_method.bind(self).(*targs)
          unless tblock.nil?
            tblock.call(result);
          else
            Thread.current[:return_value] = result
          end
        end
      end # define_method
      @@methods_asyncing.delete(method)
      @@asynced_methods.add(instance_method method)
    end
  end
end
