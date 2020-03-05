require 'fakefs/safe'

module TestHelpers
  module FakeFS
    def setup
      super
      ::FakeFS.clear!
      ::FakeFS.activate!
      ::FakeFS::File.any_instance.stubs(:flock).returns(true)
    end

    def teardown
      ::FakeFS.deactivate!
      super
    end
  end
end
