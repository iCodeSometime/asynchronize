require 'date'

Gem::Specification.new do |s|
  s.name = 'asynchronize'
  s.version = '0.2.1'
  s.date = Date.today.to_s
  s.summary = 'Easily make multiple methods asynchronous with one line of code.'
  s.description = 'Take any synchronous method, and run it asynchronously, ' +
    'without cluttering your code with repetetive boilerplate.'
  s.author = 'Kenneth Cochran'
  s.email = 'kenneth.cochran101@gmail.com'
  s.files = [
    'lib/asynchronize.rb',
    'spec/spec.rb',
    'spec/minitest_helper.rb',
    'readme.md',
    'LICENSE',
  ]
  s.test_files = [
    'spec/spec.rb',
    'spec/minitest_helper.rb'
  ]
  s.homepage = 'https://github.com/kennycoc/asynchronize'
  s.license = 'MIT'
end
