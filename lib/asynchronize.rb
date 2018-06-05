module Asynchronize
  require 'set'
  def self.included(base)
    base.class_eval do
      ##
      # Call to asynchronize a method.
      #
      #   Calling this does two things
      #   1. Creates and prepends a module named class + Asynchronized
      #   2. Defines each of the passed methods on that module.
      #
      #   - The new methods wrap the old method within Thread.new.
      #   - Subsequent calls only add methods to the existing Module.
      #
      # @param methods [Symbol] The methods to be asynchronized.
      # @example To add any number of methods to be asynchronized.
      #   asynchronize :method1, :method2, :methodn
      #
      def self.asynchronize(*methods)
        module_name = self.name.split('::')[-1] + 'Asynchronized'
        if const_defined?(module_name)
          async_container = const_get(module_name)
        else
          async_container = const_set(module_name, Module.new)
          prepend async_container
        end

        async_container.instance_eval do
          Asynchronize._define_methods_on_object(methods, self)
        end
      end
    end
  end

  private
  def self._define_methods_on_object(methods, obj)
    methods.each do |method|
      next if obj.methods.include?(method)
      obj.define_method(method) do |*args, &block|

        return Thread.new(args, block) do |targs, tblock|
          Thread.current[:return_value] = super(*targs)
          tblock.call(Thread.current[:return_value]) if tblock
        end
      end
    end
  end
end
