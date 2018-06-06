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
      # @param methods [Symbol] The methods to be asynchronized.
      # @example To add any number of methods to be asynchronized.
      #   asynchronize :method1, :method2, :methodn
      #
      def self.asynchronize(*methods)
        async_container = Asynchronize.get_container_for(self)
        async_container.instance_eval do
          Asynchronize._define_methods_on_object(methods, self)
        end
      end
    end
  end

  private
  ##
  # Define methods on object
  #
  #   For each method in the array
  #
  #   - If method already defined, go to the next.
  #   - If method does not exist, create it and go to the next.
  #
  # @param methods [Array<Symbol>] The methods to be bound.
  # @param obj [Object] The object for the methods to be defined on.
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
  #    The actual method that will be defined when calling asynchronize.
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
  # Container setup
  #
  #   - If the container module is defined, return it.
  #   - If the container module is not defined, create, prepend, and return it.
  #
  def self.get_container_for(obj)
    module_name = get_container_name(obj.name)

    if obj.const_defined?(module_name) 
      async_container = obj.const_get(module_name)
    else
      async_container = obj.const_set(module_name, Module.new)
      obj.prepend async_container
    end
    
    return async_container # required return as prepend is last operation
  end
  
  
  ##
  # Get Container Name
  #  
  #   Does two things
  #   1. Trims all but the last child on the namespace
  #   2. Appends 'Asynchronized'
  #
  def self.get_container_name(name)
    name = name.split('::').last + 'Asynchronized'
  end
end
