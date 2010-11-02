require 'test/unit'
require 'fakefs'
require 'stringio'
require File.expand_path(File.dirname(__FILE__)+'/../lib/task_adder.rb')
require File.expand_path(File.dirname(__FILE__)+'/../task_filter.rb')

class TestTaskAdder < Test::Unit::TestCase
  
  class FakeFS::File
    def flock(locking_constant) 
      true
    end
  end

  def setup
    FakeFS.activate!
    FakeFS::FileSystem.clear
  end

  def test_illegal_argument
    assert_raises ArgumentError do
      TaskAdder.new(nil,nil)
    end
    
    assert_raises ArgumentError do
      TaskAdder.new("available",nil)
    end
    
    assert_raises ArgumentError do
      TaskAdder.new(nil, "available")
    end
  end
  
  def test_correct_dir_substitution
    input_queue_dir = "/opt/queue"
    expected_output_dir = "/opt/queue/"
    
    sq_adder = TaskAdder.new(input_queue_dir, "queue.txt")
    assert_equal expected_output_dir, sq_adder.queue_dir
  end
  
  def test_not_dir_substitution
    input_queue_dir = "/opt/queue/"
    expected_output_dir = "/opt/queue/"
    
    sq_adder = TaskAdder.new(input_queue_dir, "queue.txt")
    assert_equal expected_output_dir, sq_adder.queue_dir
  end
  
  def test_if_file_is_created
    expected_filename = "/queue/queue.txt.0"
    
    FileUtils.mkdir_p "/queue"
    sq_adder = TaskAdder.new("/queue","queue.txt")
    
    sq_adder.add("my task",0)
    assert File.exist?(expected_filename), "file #{expected_filename} was not created"
  end
  
  def test_if_file_content_is_added_correctly_one_task
    expected_filename = "/queue/queue.txt.1"
    
    FileUtils.mkdir_p "/queue"
    sq_adder = TaskAdder.new("/queue","queue.txt")
    
    sq_adder.add("my task",1)
    
    File.open(expected_filename) do |file|
      assert_equal("my task", file.read.chomp)
      assert_equal("", file.read)
    end
  end
  
  def test_if_file_content_is_added_correctly_multiple_tasks
    expected_filename = "/queue/queue.txt.1"
    
    FileUtils.mkdir_p "/queue"
    sq_adder = TaskAdder.new("/queue","queue.txt")
    
    tasks = Array.new
    
    tasks << "my first task"
    tasks << "my second task"
    tasks << "my third task" 
    
    sq_adder.add(tasks,1) 
    
    File.open(expected_filename) do |file|
      file_content = file.read
      file_content.chomp!
      
      lines = file_content.split("\n")
      
      assert_equal(3, lines.length)
      assert_equal("my first task", lines[0])
      assert_equal("my second task", lines[1])
      assert_equal("my third task", lines[2])
    end
  end
  
  def test_basic_filter_functionality
    expected_filename = "/queue/queue.txt.9"
    FileUtils.mkdir_p "/queue"
    sq_adder = TaskAdder.new("/queue","queue.txt")
    
    tasks = Array.new
    
    tasks << "my first task"
    tasks << "my second task"
    tasks << "my third task"
    
    sq_adder.add(tasks,-1) 
    
    File.open(expected_filename) do |file|
      file_content = file.read
      file_content.chomp!
      
      lines = file_content.split("\n")
      
      assert_equal(3, lines.length)
      assert_equal("my first task", lines[0])
      assert_equal("my second task", lines[1])
      assert_equal("my third task", lines[2])
    end
  end
  
  def test_custom_filter_implementation
    
    my_filter = TaskFilter.new
    def my_filter.filter(task_name, prio, current_date); 
      search_hash = { "work" => 1, "fun" => 7, "something in between" => 3}
      prio_to_return = 9
      
      search_hash.each do |key, value|
        if task_name.downcase.include?(key.downcase)
          prio_to_return = value
          break;
        end
      end
      
      return prio_to_return
    end
      
    FileUtils.mkdir_p "/queue"
    sq_adder = TaskAdder.new("/queue","queue.txt")
    
    tasks = Array.new
    tasks << "do some work"
    tasks << "do nothing"
    tasks << "have some fun"
    tasks << "do something in between"

    
    sq_adder.add(tasks,-1, my_filter)
    
    expected_files = Array.new
    expected_files << "/queue/queue.txt.1"
    expected_files << "/queue/queue.txt.3"
    expected_files << "/queue/queue.txt.7"    
    expected_files << "/queue/queue.txt.9"
    
    expected_tasks = Array.new
    expected_tasks << tasks[0]
    expected_tasks << tasks[3]
    expected_tasks << tasks[2]
    expected_tasks << tasks[1]
    
    expected_files.each_index do |i|
      assert File.exist?(expected_files[i]), "file #{expected_files[i]} was not created"
      
      f = File.open(expected_files[i],'r')
      file_content = f.read
      file_content.chomp!
      lines = file_content.split("\n")
      
      assert_equal(1, lines.length)
      assert_equal(expected_tasks[i],lines[0])
    end
  end
  
  
  def teardown
      FakeFS.deactivate!
  end

end