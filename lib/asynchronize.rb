module Asynchronize
  require 'set'
  def self.included(base)
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
      if method_defined? :method_added
        alias_method :old_method_added, :method_added
        undef_method(:method_added)
      end

      def self.method_added(method)
        # Don't do anything else if we're not actually adding a new method
        return if @@methods_asyncing.include? method
        old_method_added(method) if method_defined? :old_method_added
        return unless @@methods_to_async.include? method
        Asynchronize.create_new_method(method, self)
      end
    end
  end

  def self.create_new_method(method, klass)
    klass.instance_eval do
      old_method = instance_method(method)
      # Can't just store the method name, since it would break if the method
      # was redefined.
      return if @@asynced_methods.include?(old_method)
      undef_method method

      @@methods_asyncing.add(method)
      define_method(method) do |*args, &block|
        return _build_thread(old_method, args, block)
      end
      @@methods_asyncing.delete(method)
      @@asynced_methods.add(instance_method(method))
    end
  end

  private
  def _build_thread(old_method, args, block)
    return Thread.new(old_method, args, block) do |told_method, targs, tblock|
      result = told_method.bind(self).call(*targs)
      if tblock.nil?
        Thread.current[:return_value] = result
      else
        tblock.call(result)
      end
    end
  end
end
