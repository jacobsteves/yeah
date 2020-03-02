require 'yeah'

module Yeah
  module EntryPoint
    def self.call(args)
      cmd, command_name, args = Yeah::Resolver.call(args)
      Yeah::Executor.call(cmd, command_name, args)
    end
  end
end
