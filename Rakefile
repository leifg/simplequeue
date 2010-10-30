$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'test')

desc "Run tests"
task :test do
  puts $LOAD_PATH
  Dir['test/**/*_test.rb'].each { |file| require File.expand_path(File.dirname(__FILE__)) + "/" + file }
end

task :default => :test