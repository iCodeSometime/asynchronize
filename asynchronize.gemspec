require 'date'

Gem::Specification.new do |s|
  s.name = 'asynchronize'
  s.version = 0
  s.date = Date.today.to_s
  s.summary = 'Easily make multiple methods asynchronous at once.'
  s.description = 'Take any synchronous method, and run it asynchronously, ' +
    'without cluttering your code with repetetive boilerplate.'
  s.authors = ['Kenneth Cochran']
  s.email = 'TOD@g.co'
  # TODO: Rakefile, License, Readme, Gemfile
  s.files = [
    'lib/asynchronize.rb'
  ]
  s.homepage = 'https://TODO.com'
  s.license = 'MIT'
end
