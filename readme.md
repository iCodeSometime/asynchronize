[![Build Status](https://travis-ci.org/kennycoc/asynchronize.svg?branch=master)](https://travis-ci.org/kennycoc/asynchronize)
[![Maintainability](https://api.codeclimate.com/v1/badges/30d40e270a3d7a0775a9/maintainability)](https://codeclimate.com/github/kennycoc/asynchronize/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/30d40e270a3d7a0775a9/test_coverage)](https://codeclimate.com/github/kennycoc/asynchronize/test_coverage)
# Asynchronize
### A declarative syntax for creating asynchronous methods.

Find yourself writing the same boilerplate for all your asynchronous methods?
Get dry with asynchronize.

Just add to your Gemfile and `bundle` or install globally with
`gem install asynchronize`

## Usage
Create a class with asynchronized methods
```Ruby
require 'asynchronize'
class Test
  include Asynchronize
  # Can be called before or after method definitions. I prefer it at the top of classes.
  asynchronize :my_test, :my_other_test
  def my_test
    return 'testing'
  end
  def my_other_test
    #do stuff here too
  end
end
```

Now, to call those methods.

The method's return value can be accessed either with `Thread#value` or through
the thread param `:return_value` (make sure the thread is finished first!)
```Ruby
thread = Test.new.my_test
puts thread.value          # > testing
puts thread[:return_value] # > testing
```

Or if called with a block, the method's return value will be passed as a
parameter. In this case, the original function's return value is still
accessible at `:return_value`, and `Thread#value` contains the value returned
from the block.
```Ruby
thread = Test.new.my_test do |return_value|
  return_value.length
end
puts thread.value          # > 7
puts thread[:return_value] # > testing
```

As you can see, it's just a regular thread. Make sure you call either
`Thread#value` or`Thread#join` to ensure it completes before your process exits,
and to catch any exceptions that may have been thrown!

## Inspiration
While working on another project, I found myself writing this way too often:
```Ruby
def method_name(args)
  Thread.new(args) do |targs|
    # Actual code.
  end
end
```
It's extra typing, and adds an unneeded extra layer of nesting. I couldn't find
an existing library that wasn't trying to add new layers of abstraction I didn't
need; sometimes you just want a normal thread. Now, just call asynchronize to
make any method asynchronous.

## Versioning Policy
Beginning with version 1.0.0, this project will follow [Semantic
Versioning](https://semver.org). Until then, the patch number (0.0.x) will be
updated for any changes that do not affect the public interface. Versions that
increment the minor number (0.x.0) will have at least one of the following. A new
feature will be added, some feature will be deprecated, or some previously
deprecated feature will be removed. Deprecated features will be removed on the
very next version that increments the minor version number.

## FAQ
### Doesn't metaprogramming hurt performance?
Not at all! What we're doing in this project actually works exactly like
inheritance, so it won't be a problem.

### So, how does it work?
When you `include Asynchronize` it creates an `asynchronize` method on your
class. 

```ruby
require 'asynchronize'
class Test
  include Asynchronize
end
Test.methods - Object.methods # > [:asynchronize]
```

The first time you call this method with any arguments, it creates a new
module with the methods you define. It uses `Module#prepend` to insert itself at the top of the
class's inheritance chain. This means that its methods are called before the class's own methods.

```ruby
class Test
  asynchronize :my_test
  def my_test
    return 'testing'
  end
end

Test.constants # > [:Asynchronized]
Test::Asynchronized.instance_methods # > [:my_test]
Test.ancestors # > [Test::Asynchronized, Test, Asynchronize, Object, Kernel, BasicObject]
```

Where the implementation of Test::Asynchronized#my_test (and any other method) is like
```ruby
return Thread.new(args, block) do |thread_args, thread_block|
  Thread.current[:return_value] = super(*thread_args)
  next thread_block.call(Thread.current[:return_value]) if thread_block
  Thread.current[:return_value]
end
```
This implementation allows you to call asynchronize at the top of the class and
then define the methods below. Since it changes how you interact with those
method's return values, I thought it was important to allow this.

### Why do I need another gem? My code's bloated enough as it is?
It's super tiny. Just a light wrapper around the existing language features.
Seriously, it's just around forty lines of code. Actually, according to
[cloc](https://www.npmjs.com/package/cloc) there's almost four times as many
lines in the tests as the source. You should read it. I'd love feedback!

### Do you accept contributions?
Absolutely!
1. Fork it (https://github.com/kennycoc/asynchronize/fork)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new pull request.

It's just `bundle` to install dependencies, and `rake` to run the tests.

### What's the difference between asynchronize and promises/async..await?
Those and other similar projects aim to create an entirely new abstraction to
use for interacting with threads. This project aims to be a light convenience
wrapper around the existing language features. Just define a regular method,
then interact with its result like a regular thread.

### What Ruby versions are supported?
Ruby 2.3 and up. Unfortunately, Ruby versions prior to 2.0 do not support
`Module#prepend` and are not supported. Ruby versions prior to 2.3 have a bug
preventing usage of `super` with `define_method`. I'm unable to find a suitable
workaround for this issue. (`method(__method__).super_method.call` causes
problems when a method inherits from the asynchronized class.)

Luckily, all major Ruby implementations support Ruby language version 2.3, so I
don't see this as a huge problem. If anyone wants support for older versions,
and knows how to work around this issue, feel free to submit a pull request.

We explicitly test against the following versions:
 - Matz Ruby 2.6.0
 - Matz Ruby 2.3.8
 - JRuby 9.2.5.0 (ruby language version 2.5.x)
 - Rubinius 3.100 (ruby language version 2.3.1)

### Is it any good?
[Yes](https://news.ycombinator.com/item?id=3067434)

### Does anyone like it?
It was [featured in Ruby Weekly!](https://rubyweekly.com/issues/402)
Also mentioned in russian dev news aggregator [dou.ua](https://dou.ua/lenta/digests/ruby-digest-19)
## License
MIT
