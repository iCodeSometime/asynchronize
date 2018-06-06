module Asynchronize
  def self.included(base)
    base.class_eval do
      ##
      # Call to asynchronize a method.
      #
      #   This does two things
      #   1. Creates and prepends a module named "<className> + Asynchronized"
      #   2. Defines each of the passed methods on that module.
      #
      #   - The new methods wrap the old method within Thread.new.
      #   - Subsequent calls only add methods to the existing Module.
      #
      #   @param methods [Symbol] The methods to be asynchronized.
      #   @example To add any number of methods to be asynchronized.
      #   asynchronize :method1, :method2, :methodn
      #
      def self.asynchronize(*methods)
        # require 'pry'; binding.pry
        module_name = Asynchronize.get_container_name(self.name)
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

  ##
  # Defines an asynchronous wrapping method with the given name on an object.
  #
  #   Always defines each given method unless it is already defined on obj;
  #   in that case, it will continue to define the remainder of the methods.
  #
  #   @param methods [Array<Symbol>] The methods to be created.
  #   @param obj [Object] The object for the methods to be created on.
  #
  private
  
  ##
  #  Define methods on object
  #
  #    1) If method already defined, do nothing.
  #    2) If method does not exist, call to build it on object.
  #
  #   @param methods [Array<Symbol>] The methods to be bound.
  #   @param obj [Object] The object for the methods to be defined on.
  #
  def self._define_methods_on_object(methods, obj)
    methods.each do |method|
      next if obj.methods.include?(method)
      obj.send(:define_method, method, _build_method)
    end
  end

  ##
  #  Build Method
  #
  #    Always builds  exact same proc. Placed into a named method for clarity.
  #
  def self._build_method
    return Proc.new do |*args, &block|
      return Thread.new(args, block) do |thread_args, thread_block|
        Thread.current[:return_value] = super(*thread_args)
        thread_block.call(Thread.current[:return_value]) if thread_block
      end
    end
  end
  
  ##
  # Get Container Name
  #  
  #  Does two things
  #  - Trims all but the last child on the namespace
  #  - Appends 'Asynchronized'
  #
  def self.get_container_name(name)
    name.split('::').last + 'Asynchronized'
  end
end