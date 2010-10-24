#!/usr/bin/env ruby
require 'rubygems'
require 'configatron'
require 'logger'
require 'escape'

log = Logger.new(File.expand_path(File.dirname(__FILE__) + "/log/daemon.log"))
@@config = configatron.configure_from_yaml(File.expand_path(File.dirname(__FILE__) + "/config/config.yml"))
queue_file = @@config['queue']

def notify (filename, success)
  if filename and @@config['growlnotify_cli']
    success_string = success ? "succeeded" : "failed"
    sucess_title = success ? "success" : "fail"
    success_image = success ? File.expand_path(File.dirname(__FILE__) + "/img/success.png") : File.expand_path(File.dirname(__FILE__) + "/img/fail.png") 
    options = "-n simplequeue -t #{sucess_title} --image '#{success_image}' -m 'Processing #{filename} #{success_string}'"
    system %(#{@@config['growlnotify_cli']} #{options} &)
  end
end

loop do
  log.level = Logger::DEBUG
  log.info("--- simplequeue daemon started ---")

  log.debug "read from queue file: " + queue_file

  filename = nil
  rest_of_file = nil

  File.open(queue_file,"r") do |f| 
    filename = f.gets
    rest_of_file = f.read
  end

  File.open(queue_file,"w+") do |f|
    f.flock(File::LOCK_EX)
    f.write(rest_of_file)
    f.flock(File::LOCK_UN)
  end

  if filename and not filename.strip.empty?
    filename.chomp!
    log.info("read the line: " + filename)
    filename = Escape.shell_single_word(filename)
    process_command = File.expand_path(File.dirname(__FILE__) + "/scripts/process ") + filename
  
    log.debug("executing line: $"+process_command+"$")
    
    success = true
    success = system process_command
    log.info("return value or script execution: "+success.to_s)
    
    if (success)
      log.info("execution successfull")
      system File.expand_path(File.dirname(__FILE__) +"/scripts/success")+" "+filename
    else
      log.error("execution failed")
      system File.expand_path(File.dirname(__FILE__) +"/scripts/error")+" "+filename
    end
    notify filename, success
  end  
  sleep(5)
end