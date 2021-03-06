require 'test_helper'
require 'fileutils'

describe Yeah::Project do
  include TestHelpers::FakeFS

  let(:directory) { "some/fake/path/to" }
  let(:path) { "#{directory}/yeah.yml" }
  let(:project_instance) { Yeah::Project.new }

  before do
    Yeah::Project.instance_variable_set(:@at, nil)
    Yeah::Project.instance_variable_set(:@dir, nil)
  end

  describe '.load_yaml_file' do
    subject do
      FileUtils.mkdir_p(directory)
      File.write(path, ':some: yml')
      project_instance.send(:load_yaml_file, path)
    end

    describe 'when loading yeah.yml' do
      it 'should load the yaml' do
        assert_equal({ some: 'yml' }, subject)
      end
    end

    describe 'when not loading yeah.yml' do
      let(:path) { "#{directory}/something" }
      it 'should work on any file' do
        assert_equal({ some: 'yml' }, subject)
      end
    end
  end

  describe '.config' do
    let(:project_instance) { Yeah::Project.new(directory: directory) }

    it 'should load and cache the config with symbols' do
      FileUtils.mkdir_p(directory)
      File.write(path, ':some: yml')
      assert_equal({ some: 'yml' }, project_instance.config)
      File.delete(path)
      assert_equal({ some: 'yml' }, project_instance.config)
    end

    it 'should load and cache the config with strings' do
      FileUtils.mkdir_p(directory)
      File.write(path, 'some: yml')
      assert_equal({ 'some' => 'yml' }, project_instance.config)
      File.delete(path)
      assert_equal({ 'some' => 'yml' }, project_instance.config)
    end

    it 'should raise error when yeah.yml doesnt exist' do
      assert_raises(StandardError) { project_instance.config }
    end

    it 'should raise error when yaml is not a hash' do
      project_instance.stubs(:load_yaml_file).returns('')
      assert_raises(Yeah::ProjectError) { project_instance.config }
    end
  end

  describe '.custom_command_names' do
    describe 'when there are no commands in the config' do
      it 'should return an empty array' do
        project_instance.stubs(:config).returns({})
        assert_equal([], project_instance.custom_command_names)
      end
    end

    describe 'when there are custom commands in the config' do
      it 'should pull the keys from the config' do
        project_instance.stubs(:config).returns({
          'commands' => { a: 'a', b: 'b' },
        })
        assert_equal([:a, :b], project_instance.custom_command_names)
      end
    end
  end

  describe '.at' do
    it 'should recurse directories' do
      dir = File.realpath('./')
      path = 'a/b/c/d'
      FileUtils.mkdir_p("#{dir}/#{path}")
      FileUtils.touch("#{dir}/yeah.yml")
      assert_equal(dir, Yeah::Project.at("#{dir}/#{path}").directory)
    end

    it 'should return an EmptyProject if yeah.yml file is not found here' do
      dir = File.realpath('./')
      path = 'a/b/c/d'
      FileUtils.mkdir_p("#{dir}/#{path}")
      Yeah::Project.any_instance.expects(:load_yaml_file).never
      assert_empty(Yeah::Project.at("#{dir}/#{path}").config)
    end

    it 'should cache results' do
      FileUtils.mkdir_p(directory)
      File.write(path, ':some: yml')
      assert(Yeah::Project.at(path).directory)
      File.delete(path)
      assert(Yeah::Project.at(path).directory)
    end

    it 'should return an EmptyProject' do
      Yeah::Project.any_instance.expects(:load_yaml_file).never
      assert_empty(Yeah::Project.at(nil).config)
    end
  end
end
