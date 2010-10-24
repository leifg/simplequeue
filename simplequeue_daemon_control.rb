#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'

Daemons.run("simplequeue_daemon.rb") do
  loop do
    sleep(5)
  end
end