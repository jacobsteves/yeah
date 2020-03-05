require 'fakefs/safe'

module TestHelpers
  module FakeFS
    def setup
      super
      ::FakeFS.clear!
      ::FakeFS.activate!
    end

    def teardown
      ::FakeFS.deactivate!
      super
    end
  end
end
