[![Build Status](https://travis-ci.org/kennycoc/asynchronize.svg?branch=master)](https://travis-ci.org/kennycoc/asynchronize)
[![Maintainability](https://api.codeclimate.com/v1/badges/30d40e270a3d7a0775a9/maintainability)](https://codeclimate.com/github/kennycoc/asynchronize/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/30d40e270a3d7a0775a9/test_coverage)](https://codeclimate.com/github/kennycoc/asynchronize/test_coverage)
# Asynchronize
### The easiest way to make multiple methods asynchronous.

Find yourself writing the same boilerplate for all your asynchronous methods?
Get dry with asynchronize.

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

Now, to call those methods.
You can manage the thread yourself; the returned value will be in the thread
variable `:return_value` once it returns.
```Ruby
thread = Test.new.my_test
thread.join
puts thread[:return_value] # > test
```

Or for convenience, you can just pass it a block.
The return value, will still be in the thread variable `:return_value`
```Ruby
Test.new.my_test do |return_value|
  puts return_value # > test
end
```

## Inspiration
I got tired of writing this over and over.
```Ruby
def method_name(args)
  Thread.new(args) do |targs|
    # Actual code.
  end
end
```
It's extra typing, adds an unneeded extra layer of nesting, and just feels
dirty. I couldn't find an existing library that wasn't trying to solve other
problems I didn't have. Now, just call asynchronize to make any method
asynchronous.

## Versioning Policy
Once I feel like this is ready for production code - version 1.0.0, this project
will follow [Semantic Versioning](https://semver.org) until then, the patch
number (0.0.x) will be updated for any changes that do not affect the public
interface. Versions that increment the minor number will have at least one of
the following. A new feature will be added, some feature will be deprecated, or
some previously deprecated feature will be removed. Deprecated features will be
removed on the very next version that increments the minor version number.

## FAQ
### Doesn't metaprogramming hurt performance?
Not at all! We're actually totally redefining the methods, so the method itself
is exactly as efficient as it would have been had you wrote it that way
originally.

### So, how does it work?
When you `include Asynchronize` it does two things.
1. It defines the asynchronize method for your class
2. It defines method_added on your class.

When you call asynchronize, it creates a set containing all of the methods you
want asynchronized. If they already exist, they are modified; otherwise,
method_added checks for them with every new method you add to the class. This
way, you can call asynchronize any time, and know that the methods will be
asynchronized when you use them.

### So, does that mean I can't use asynchronize if I already use method_added?
We check for and alias your old method_added. It will be called before
anything else. Of course, if you define method_added after including
Asynchronize, you have to do the same and be careful to not overwrite ours!

### Why do I need another framework? My code's bloated enough as it is?
It's super tiny. Just a light wrapper around the existing language features.
Seriously, it's just around fifty lines of code. Actually, according to
[cloc](https://www.npmjs.com/package/cloc) there's twice as many lines in the
tests as the source. You should read it, I'd love feedback!

### Do you accept contributions?
Absolutely! If your use case isn't compatible with the project, you find a
bug, or just want to donate some tests; make an issue or send a PR please.

### What's the difference between this and promises?
This attempts to be a very lightweight wrapper around threads. There's no new
interface to use, just define a regular method, and interact with it like a
regular thread.

## License
MIT
