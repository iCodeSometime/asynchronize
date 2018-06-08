require 'date'
code_repo = 'https://github.com/kennycoc/asynchronize'

Gem::Specification.new do |s|
  s.name = 'asynchronize'
  s.version = '0.3.0'
  s.date = Date.today.to_s
  s.summary = 'A declarative syntax for creating threads.'
  s.description = %w{Sometimes you just want a regular thread without the
                    overhead of a whole new layer of abstraction.
                    Asynchronize provides a declarative syntax to wrap any
                    method in a Thread.}.join(' ')
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
  s.required_ruby_version = '>= 2.3'
  s.post_install_message = 'Making something cool with asynchronize? ' +
                           'Let me know at ' + code_repo + '!!'
  s.homepage = code_repo
  s.license = 'MIT'
end
