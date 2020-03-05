#!/usr/bin/ruby --disable-gems

lib_path = File.expand_path("../../../lib", __FILE__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

ENV['SHELLPID'] ||= Process.ppid.to_s
ENV['USER_PWD'] ||= Dir.pwd

$original_env = ENV.to_hash

require 'yeah'

CLI::UI::StdoutRouter.disable
