require 'date'

Gem::Specification.new do |s|
  s.name = 'asynchronize'
  s.version = 0
  s.date = Date.today.to_s
  s.summary = 'Easily make multiple methods asynchronous at once.'
  s.description = 'Take any synchronous method, and run it asynchronously, ' +
    'without cluttering your code with repetetive boilerplate.'
  s.author = 'Kenneth Cochran'
  s.email = 'kenneth.cochran101@gmail.com'
  s.files = [
    'lib/asynchronize.rb',
    'spec/spec.rb',
    'asynchronize.gemspec',
    'Rakefile',
    'readme.md'
  ]
  s.test_files = [
    'spec/spec.rb'
  ]
  s.homepage = 'https://github.com/kennycoc/asynchronize'
  s.license = 'MIT'
end
