require 'date'
require File.expand_path(File.dirname(__FILE__)+'/../task_filter.rb')

class TaskAdder
    attr_reader :queue_dir, :queue_prefix
  
  def initialize(queue_dir, queue_prefix)
    if !queue_dir || !queue_prefix 
      raise ArgumentError, "please specify path to queue and a prefix (dir: #{queue_dir}, prefix: #{queue_prefix})"
    end
    
    unless queue_dir =~ /\/$/
      queue_dir = queue_dir + "/"
    end
    
    @queue_dir = queue_dir
    @queue_prefix = queue_prefix
  end

  def add (input, prio, task_filter = TaskFilter.default_filter)
    if not File.exist? @queue_dir 
      raise IOError, "Directory for queue (#{queue_dir}) does not exist"
    end
     
    queue_file = file_from_prio(prio)
    
    lines = Array.new
    
    if input.class != Array
      lines << input.to_s
    else
      lines = input
    end
    
    lines.each do |line_to_add|
      cur_prio = task_filter.filter(line_to_add, prio, DateTime::now)
      f = File.open(file_from_prio(cur_prio), 'a')
      f.flock(File::LOCK_EX)
      f.puts line_to_add
      f.flock(File::LOCK_UN)
      f.close
    end
  end

  def file_from_prio(prio)
    return "#{@queue_dir}#{@queue_prefix}.#{prio}"
  end

end