require 'test_helper'

describe Yeah::Commands::Custom do
  include TestHelpers::FakeFS

  let(:cmd_name) { 'custom' }
  let(:cmd) { Yeah::Commands::Custom }
  let(:cmd_instance) { cmd.new }

  describe '.valid_command' do
    let(:command) { nil }
    subject do
      cmd_instance.send(:valid_command, command)
    end

    describe 'when cmd is nil' do
      it 'should return false' do
        refute subject
      end
    end

    describe 'when cmd is an array' do
      let(:command) do
        { 'run' => ['a', 'b'] }
      end

      it 'should return true' do
        assert subject
      end
    end

    describe 'when cmd is a String' do
      let(:command) do
        { 'run' => 'a' }
      end

      it 'should return true' do
        assert subject
      end
    end
  end

  describe '.run' do
    let(:definition) { nil }
    subject do
      cmd_instance.send(:run, definition)
    end

    describe 'when tasks to run is an array' do
      let(:definition) do
        {
          'run' => [
            'a', 'b'
          ]
        }
      end
      it 'should execute them all' do
        cmd_instance.expects(:execute).with('a', [])
        cmd_instance.expects(:execute).with('b', [])
        subject
      end
    end

    describe 'when tasks to run is a string' do
      let(:definition) do
        {
          'run' => 'a'
        }
      end
      it 'should execute it' do
        cmd_instance.expects(:execute).with('a', [])
        subject
      end
    end

    describe 'when run with args' do
      let(:args) { ['-a', '-l'] }
      let(:definition) do
        {
          'run' => 'a'
        }
      end
      subject do
        cmd_instance.send(:run, definition, args)
      end

      it 'should execute it' do
        cmd_instance.expects(:execute).with('a', args)
        subject
      end
    end
  end

  describe 'execute' do
    let(:command) { 'ls' }
    let(:args) { [] }
    subject do
      cmd_instance.send(:execute, command, args)
    end

    it 'aborts if system fails' do
      cmd_instance.stubs(:system).returns(false)
      assert_raises (Yeah::Abort) { subject }
    end

    it 'continues if system succeeds' do
      cmd_instance.stubs(:system).returns(true)
      subject
    end

    it 'should call another yeah command if specified' do
      command_def = { run: [] }
      cmd_instance.stubs(:command).with(command).returns(command_def)
      cmd_instance.expects(:run).with(command_def, args)
      subject
    end

    describe 'when cmd is specified with arguments or flags' do
      let(:command) { 'command -f -name test' }
      let(:args) { %w(-a -l) }

      it 'should split cmd flags when executing' do
        cmd_instance.expects(:system).with('command', '-f', '-name', 'test', '-a', '-l').returns(true)
        subject
      end
    end
  end
end
