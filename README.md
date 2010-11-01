# simplequeue

simplequeue is a simple queueing utility, which can read tasks from a text file. Everything that can be expressed as a single line in a plain-text file is a task.

## Features

- queueing tasks inside .txt files
- separate client for adding tasks
- execution of `success`- and `error`-scripts after processing tasks
- growl notification
- simple extending of configuration using yml
- daemonizing of task processing
- assigning tasks priorities (0-9 are supported so far, default prio is 9)
- filter tasks and assign priorities according to task-name or current date

## Dependencies

- configatron
- escape
- daemons

for running the unit tests, you'll also need fakefs

## Usage

### Configuration

To get started, copy the file `config/config.yml.example` to `config/config.yml` abd add the absolute path to your `queue_dir`. All the files necessary for queueing will be stored in this directory. Specify a `queue_prefix` if you want the queue files to start differently than `queue.txt`.
Write the script for the task to be executed in `scripts/process`. The task will be given as a string as first parameter to the script.
If you want you can add custom handling for success and error in `scripts/success` and `scripts/error`.
To enable growl notification just ensure that the path to the [growlnotify](http://growl.info/extras.php) binary is set correctly in `growlnotify_cli`.

#### Adding Tasks

To add a task to the queue execute `simplequeu.rb <taskname> -p<prio>`. For adding multiple tasks, separate them by spaces (shell globs are supported - especially handy for adding filenames as tasks). The tasks will be added to a .txt file in `queue_dir`. The priority will be appended to this file.

For example: `simplequeue "a simple task" -p7` adds the task "a simple task" to the file `/opt/queue/queue.txt.7`. The queue files with the highest priority (smalles number) will be executed first. When all the tasks in this file are executed, the next queue_file which has the next highest priority (next greater number) will be executed. Task executing will not be interrupted. If you add a prio 1 task, while a prio 9 task is executed, the prio 1 task is executed next.

#### Priority Filtering

Additionally you have the opportunity to assign a priority according to the task-name, current date (or incoming prio).

Just implement the method `(task_name, prio, current_date)` in the file `task_filter.rb` (plain ruby). If you add the tasks using the `simplequeue.rb` command-line tool, you'll get 3 parameters:

- task_name: (the name of the task to be added)
- prio: (the priority that has been set using the -p flag (-1 if no prio was set))
- current_date: the current date

The default behaviour is:

- return prio when set, return 9 when not set

Here's an example implementation of assigning priorities according to their name:

	class TaskFilter

		def filter(task_name, prio, current_date); 
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
	end

#### Start Task Queue

To start queue process simply start `simplequeue_daemon.rb`. 
For daemonizing execute `simplequeue_daemon_control.rb start`.

## Attribution

The icons I used for the growl notification I took from here: http://www.icojoy.com/articles/46/.