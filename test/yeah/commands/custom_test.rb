require 'test_helper'

describe Yeah::Commands::Custom do
  include TestHelpers::FakeFS

  let(:cmd_name) { 'custom' }
  let(:cmd) { Yeah::Commands::Custom }
  let(:cmd_instance) { cmd.new }

  describe '.call' do
    subject do
      cmd.call(args, cmd_name)
    end
  end

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
        cmd_instance.expects(:execute).with('a')
        cmd_instance.expects(:execute).with('b')
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
        cmd_instance.expects(:execute).with('a')
        subject
      end
    end
  end
end
