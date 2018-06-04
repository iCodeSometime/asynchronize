require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "spec/*spec.rb"
  t.ruby_opts = ["--debug"] if RUBY_ENGINE == 'jruby'
end

desc "Run tests"
task :default => :test
