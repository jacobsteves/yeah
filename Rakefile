$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require_relative 'bin/support/load_project'
require 'rake/testtask'
require 'rubocop/rake_task'

TEST_ROOT = File.expand_path('../test', __FILE__)

Rake::TestTask.new do |t|
  t.libs += ["test"]
  t.test_files = FileList[File.join(TEST_ROOT, '**', '*_test.rb')]
  t.verbose = false
  t.warning = false
end

RuboCop::RakeTask.new(:style) do |t|
  t.options = ['--display-cop-names']
end

task(default: [:test, :style])

task :console do
  exec('irb', '-r', './bin/support/load_project.rb', '-r', 'byebug')
end
