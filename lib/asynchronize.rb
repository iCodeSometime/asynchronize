module Asynchronize
  require 'set'
  def self.included(base)
      
    ## 
    # base.class_val  
    #
    #  @@asynced_methods     ... methods already asynchronized.
    #  @@methods_to_async    ... methods that should be asynchronized.
    #  @@methods_asyncing    ... method that is being asynchronized currently.
    #    ... Originally used a single value here, but that's not thread safe.
    #    Though you probably have other problems if you have multiple,
    #    threads adding methods to your class.
    #
    base.class_eval do
      @asynced_methods = Set.new
      @methods_to_async = Set.new
      @methods_asyncing = Set.new

      # Call to asynchronize a method.
      #   Method will be added to a list of methods to asynchronize.
      #
      # - If method exists, it will be redefined to an asynchronous version. 
      # - If method is not defined, method_missing will redefine it when it does.  
      # - If method is redefined afterwards, method_missing will also 
      #   synchronize that version.
      #
      # @param methods [Symbol] The methods to be asynchronized.
      # @example To add any number of methods to be asynchronized.
      #   asynchronize :method1, :method2, :methodn
      #
      def self.asynchronize(*methods)
        @methods_to_async.merge(methods.map {|m| m.hash})
        methods.each do |method|
          # If it's not defined yet, handle later with method_added.
          Asynchronize.create_new_method(method, self) if method_defined?(method)
        end
      end

      ##
      # Save the old method_added so it is not overwritten.
      #
      if self.methods.include?(:method_added)
        singleton_class.send(:alias_method, :old_method_added, :method_added)
        singleton_class.send(:undef_method, :method_added)
      end

      ##
      # Will asynchronize a method. 
      #
      # - If it is inherited class that hasn't included asynchronize, do nothing
      # - If it has not been asynchronized + it is in the list of  asynchronize, 
      #     then it will add it
      # - If method missing was already defined, it will call the previous
      #     method_missing before anything else Ruby calls this automatically. 
      #     When defining a method; it should not be called directly.
      #
      def self.method_added(method)
        # Return if this is an inherited class that hasn't included asynchronize
        return if @methods_asyncing.nil?
        # Return if we're already processing this method
        return if @methods_asyncing.include?(method.hash)
        @methods_asyncing.add(method.hash)
        self.old_method_added(method) if self.methods.include?(:old_method_added)
        return unless @methods_to_async.include?(method.hash)
        # This will delete from @methods_asyncing
        Asynchronize.create_new_method(method, self)
      end
    end
  end

  ##
  # Responsible for actually creating the new methods and removing the old.
  #
  def self.create_new_method(method, klass)
    klass.instance_eval do
      old_method = instance_method(method)
      return if @asynced_methods.include?(old_method.hash)
      undef_method(method)
      
      @methods_asyncing.add(method.hash)
      define_method(method, Asynchronize._build_new_method(old_method))
      @methods_asyncing.delete(method.hash)
      @asynced_methods.add(instance_method(method).hash)
    end
  end

  private
  def self._build_new_method(old_method)
    return Proc.new do |*args, &block|
      return Thread.new(old_method, args, block) do |told_method, targs, tblock|
        Thread.current[:return_value] = told_method.bind(self).call(*targs)
        tblock.call(Thread.current[:return_value]) unless tblock.nil?
      end
    end
  end
end
