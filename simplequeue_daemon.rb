#!/usr/bin/env ruby
require 'rubygems'
require 'configatron'
require 'logger'
require 'escape'

log = Logger.new(File.expand_path(File.dirname(__FILE__) + "/log/daemon.log"))
@@config = configatron.configure_from_yaml(File.expand_path(File.dirname(__FILE__) + "/config/config.yml"))
queue_dir = @@config['queue_dir']
queue_prefix = @@config['queue_prefix']

def notify(task, success)
  if task and @@config['growlnotify_cli']
    success_string = success ? "succeeded" : "failed"
    sucess_title = success ? "success" : "fail"
    success_image = success ? File.expand_path(File.dirname(__FILE__) + "/img/success.png") : File.expand_path(File.dirname(__FILE__) + "/img/fail.png") 
    options = "-n simplequeue -t #{sucess_title} --image '#{success_image}' -m \"Processing #{task} #{success_string}\""
    system ("#{@@config['growlnotify_cli']} #{options} &")
  end
end

def determine_next_file(dir, prefix)
  dir = dir + "/" unless dir =~ /\/$/
  queue_files = Dir.glob("#{dir}#{prefix}.[^a-zA-Z]")
  toReturn = nil
  
  queue_files.each do |filename|
    file = File.open(filename,'r')
    task = file.gets
    if task and not task.strip.empty?
      puts "next file: #{filename}"
      toReturn = filename
      break;
    end
  end
  toReturn
end

  log.info("--- simplequeue daemon started ---")
loop do
  log.level = Logger::INFO
  task = nil
  rest_of_file = nil

  queue_file = determine_next_file(queue_dir, queue_prefix)

  log.debug "read from queue file: " + queue_file.to_s
  if (queue_file)
    File.open(queue_file,"r") do |f| 
      task = f.gets
      rest_of_file = f.read
    end

    File.open(queue_file,"w+") do |f|
      f.flock(File::LOCK_EX)
      f.write(rest_of_file)
      f.flock(File::LOCK_UN)
    end
  
    task.chomp!
    log.debug("read the line: " + task)
    task = Escape.shell_single_word(task)
    process_command = File.expand_path(File.dirname(__FILE__) + "/scripts/process ") + task
  
    log.debug("executing line: $"+process_command+"$")
    
    success = true
    success = system process_command
    log.debug("return value or script execution: "+success.to_s)
    
    if (success)
      log.debug("execution successfull")
      system File.expand_path(File.dirname(__FILE__) +"/scripts/success")+" "+task
    else
      log.error("execution failed")
      system File.expand_path(File.dirname(__FILE__) +"/scripts/error")+" "+task
    end
    notify task, success  
    sleep(5)
  end
end