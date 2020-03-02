begin
  unshift_path = lambda do |p|
    path = File.expand_path("../../#{p}", __FILE__)
    $LOAD_PATH.unshift(path) unless $LOAD_PATH.include?(path)
  end
  unshift_path.call("lib")

  deps = %w(cli-ui cli-kit)
  deps.each { |dep| unshift_path.call("vendor/deps/#{dep}/lib") }
end

require 'cli/kit'

require 'fileutils'
require 'tmpdir'
require 'tempfile'

require 'rubygems'
require 'bundler/setup'

CLI::UI::StdoutRouter.enable

require 'byebug'
require 'minitest/autorun'
require 'minitest/unit'
require 'mocha/minitest'
