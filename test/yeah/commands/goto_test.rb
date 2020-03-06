require 'test_helper'

describe Yeah::Commands::Goto do
  include TestHelpers::FakeFS

  let(:args) { ['name'] }
  let(:cmd) { Yeah::Commands::Goto }

  let(:filename) { 'filename' }
  let(:store) do
    FileUtils.mkdir_p(Yeah::STORE_DIR)
    Yeah::Store.new(filename: filename)
  end

  before do
    cmd.any_instance.stubs(:store).returns(store)
  end

  describe ".call" do
    subject do
      cmd.call(args, 'goto')
    end

    describe "when list flag is set" do
      let(:args) { ['name', '--list']}

      it "should display the list immediately" do
        cmd.any_instance.expects(:list).once
        capture_io { subject }
      end

      describe "when data is empty" do
        it "should display help" do
          cmd.expects(:help).returns('').once
          io = capture_io { subject }
          output = io.join
          expected_output = CLI::UI.fmt("No locations saved yet.")
          assert_match(expected_output, output)
        end
      end

      describe "when data has been stored" do
        let(:data) {
          {
            "some_key": "/some/route",
            "some_key2": "/another/route"
          }
        }

        it "should display the data" do
          store.set(data)
          io = capture_io { subject }
          output = io.join
          expected_output = CLI::UI.fmt("{{cyan:some_key}}: /some/route\n{{cyan:some_key2}}: /another/route")
          assert_match(expected_output, output)
        end
      end
    end

    describe "when clear flag is set" do
      let(:args) { ['name', '--clear']}

      describe "when user continues on prompt 1" do
        describe "when user continues on prompt 2" do
          it 'should cancel' do
            CLI::UI.stubs(:ask).returns('yes').then.returns('I promise, clear all data')
            store.expects(:clear).once
            io = capture_io do
              CLI::UI::StdoutRouter.ensure_activated
              subject
            end
            assert_match('Deleted.', io.join)
          end
        end
        describe "when user cancels on prompt 2" do
          it 'should cancel' do
            CLI::UI.stubs(:ask).returns('no').then.returns('cancel')
            store.expects(:clear).never
            io = capture_io { subject }
            assert_match('Canceled.', io.join)
          end
        end
      end

      describe "when user cancels on prompt 1" do
        it 'should cancel' do
          CLI::UI.stubs(:ask).returns('no').once
          store.expects(:clear).never
          io = capture_io { subject }
          assert_match('Canceled.', io.join)
        end
      end
    end

    describe "when set flag is set" do
      describe "when a value is given" do
        let(:args) { ['name', '--set', 'value']}

        it "should save the value" do
          store.expects(:set).with('name': 'value')
          capture_io { subject }
        end
      end

      describe "when a value is not given" do
        let(:args) { ['name', '--set']}

        it "should display argument error" do
          io = capture_io { subject }
          assert_match('Missing argument.', io.join)
        end
      end
    end
  end
end
