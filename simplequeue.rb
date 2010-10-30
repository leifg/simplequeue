#!/usr/bin/env ruby
require 'rubygems'
require 'configatron'
require 'getoptlong'
require File.expand_path(File.dirname(__FILE__)+'/lib/task_adder.rb')
require File.expand_path(File.dirname(__FILE__)+'/task_filter.rb')

all_movies = ARGV
prio = -1
config = configatron.configure_from_yaml(File.expand_path(File.dirname(__FILE__) + "/config/config.yml"))

def usage()
  puts
  puts "Add tasks to queue"
  puts
  puts "Usage: ruby simplequeue.rb <tasks> [--prio=<prio>|-p <prio>]"
  puts
  puts "\t--help             Print this help"
  puts "\t--prio=<prio>      Set priority of added tasks"
  puts
  exit
end
  
if all_movies.length < 1
  usage()
end

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--prio', '-p', GetoptLong::OPTIONAL_ARGUMENT ]
  )

opts.each do |opt, arg|
  case opt
  when '--help' 
    usage
    exit 0
  when '--prio'
    prio = Integer(arg) rescue prio
  end
end

queue_prefix = config['queue_prefix'] ? config['queue_prefix'] : 'queue.txt'

begin
task_filter = TaskFilter.new
task_adder = TaskAdder.new(config['queue_dir'],queue_prefix)
task_adder.add(all_movies, prio, task_filter)
rescue Exception => e
  puts e.backtrace
end