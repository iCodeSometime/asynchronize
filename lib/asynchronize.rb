##
# Include this module to allow a declarative syntax for defining asynch methods
#
#   Defines only one method on the including class: `asynchronize`
#
module Asynchronize
  # Defines the asynchronize method
  def self.included(base)
    base.class_eval do
      ##
      # Call to asynchronize a method.
      #
      #   This does two things
      #   1. Creates and prepends a module BaseName::Asynchronized.
      #   2. Defines each of the passed methods on that module.
      #
      #   Additional notes:
      #   - The new methods wrap the old method within Thread.new.
      #   - Subsequent calls only add methods to the existing Module.
      #   - Will silently fail if the method has already been asynchronized
      #
      # @param methods [Symbol] The methods to be asynchronized.
      # @example To add any number of methods to be asynchronized.
      #   asynchronize :method1, :method2, :methodn
      #
      def self.asynchronize(*methods)
        return if methods.empty?
        async_container = Asynchronize._get_container_for(self)
        Asynchronize._define_methods_on_object(methods, async_container)
      end
    end
  end

  private
  ##
  # Define methods on object
  #
  #   For each method in the methods array
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
  # Build Method
  #
  #   This always returns the same Proc object. In it's own method for clarity.
  #
  # @return [Proc] The actual asynchronous method defined.
  #
  def self._build_method
    return Proc.new do |*args, &block|
      return Thread.new(args, block) do |thread_args, thread_block|
        Thread.current[:return_value] = super(*thread_args)
        next thread_block.call(Thread.current[:return_value]) if thread_block
        Thread.current[:return_value]
      end
    end
  end

  ##
  # Container setup
  #
  #   Creates the container module that will hold our asynchronous wrappers.
  #
  #   - If the container module is defined, return it.
  #   - If the container module is not defined, create, prepend, and return it.
  #
  # @param obj [Class] The class the module should belong to.
  # @return [Module] The already prepended module to define our methods on.
  #
  def self._get_container_for(obj)
    if obj.const_defined?('Asynchronized')
      return obj.const_get('Asynchronized')
    else
      async_container = obj.const_set('Asynchronized', Module.new)
      obj.prepend async_container
      return async_container
    end
  end
end
