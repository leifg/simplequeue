# simplequeue

simplequeue is a simple tooling utility, which can read tasks from a text file. Everything that can be expressed as a single line in a plain-text file is a task.

## Features

- queueing tasks inside a .txt file
- separate client for adding tasks to a text file
- execution of `success` and `error` after execution
- growl notification
- simple extending of configuration using yml
- daemonizing of task processing

## Dependencies

- configatron
- escape
- daemons

## Usage

To get started, just add the absolute path to your `queue` in `config/config.yml`. Write the script for the task to executed in `scripts/process`. The task will be given as a string as first parameter to the script.
If you want you can add custom handling for success and error in `scripts/success` and `scripts/error`.
To enable growl notification just ensure that the path to the [growlnotify](http://growl.info/extras.php) binary is set correctly in `growlnotify_cli`.

To add a task to the queue execute `simplequeu.rb <taskname>`. For adding multiple tasks, separate them by spaces (commandline wild cards are supported, especially handy for filename).
To start queue process simply start `simplequeue_daemon.rb`. 
For daemonizing execute `simplequeue_daemon_control.rb start`.


## Attribution

The icons I used for the growl notification I took from here: http://www.icojoy.com/articles/46/.