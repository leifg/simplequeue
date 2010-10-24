#!/usr/bin/env ruby
require 'rubygems'
require 'configatron'

config = configatron.configure_from_yaml(File.expand_path(File.dirname(__FILE__) + "/config/config.yml"))
all_movies = ARGV

if (all_movies)
  queue_file = config['queue']
  
  File.open(queue_file, 'a') do |f| 
    f.flock(File::LOCK_EX)
    all_movies.each do |file_to_add|
      f.write "#{file_to_add}\n"
    end
    f.flock(File::LOCK_UN)
  end
end