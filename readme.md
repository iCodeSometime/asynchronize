# Asynchronize
### The easiest way to make a method asynchronous.

Find yourself writing the same boilerplate for all your asynchronous methods?
Get dryyyy with asynchronize.

There are no dependencies other than Ruby.
Just install with `gem install asynchronize` or add to your Gemfile and `bundle`

## Usage
Create a class with asynchronized methods
```Ruby
require 'asynchronize'
class Test
  include Asynchronize
  # This can be called anywhere.
  asynchronize :my_test, :my_other_test
  def my_test
    return 'test'
  end
  def my_other_test
    #do stuff here too
  end
end
```

Now, to call those methods:
You can just pass it a block.
```Ruby
# Either pass a block
Test.new.my_test do |return_value|
  puts return_value
end
# > test
```

Or, you can manage the thread yourself; the returned value will be in the thread
variable `:return_value` once it returns.
```Ruby
thread = Test.new.my_test
thread.join
puts thread[:return_value]
# > test
```

## Inspiration
I got tired of writing this over and over
```Ruby
def method_name(args)
  Thread.new(args) do |targs|
    # Actual code.
  end
end
```
It's extra typing, and it adds an unneeded extra layer of nesting.
Now, I can just call asynchronize to make any methods asynchronous.

## FAQ
### Metaprogramming?? won't this hurt performance?
Not at all! We're actually totally redefining the methods, so the method itself
is exactly as efficient as it would have been had you wrote it that way
originally.

### So, how does it work?
When you `include Asynchronize` it does two things.
1. It defines the asynchronize method for your class
2. it defines method_added on your class.
asynchronize creates a set containing all of the methods you want asynchronized.
If they already exists, they are modified; otherwise, method_added checks for
them with every new method you add to the class.
This way, you can call asynchronize any time, and know that the methods will
be asynchronized.

### So, does that mean I can't use asynchronize if I already use method_added?
We check for and alias your old method_added. It will be called before
anything else. Of course, if you define method_added after including
Asynchronize, you have to do the same and be careful to not overwrite ours!

### Why do I need another framework? My code's bloated enough as it is?
It's super tiny. Just a light wrapper around the existing language features.
Seriously, it's just around fifty lines of code. Actually, according to cloc
there's twice of many lines in the tests as the source.
You should read it, I'd love feedback!

### Do you accept contributions?
Absolutely! If your use case isn't compatible with the project, you find a
bug, or just want to donate some tests; make an issue or send a PR please.

## License
MIT
