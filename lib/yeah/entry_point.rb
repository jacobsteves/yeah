require 'yeah'

module Yeah
  module EntryPoint
    def self.call(args)
      cmd, command_name, args = Yeah::Resolver.call(args)
      Yeah::Executor.call(cmd, command_name, args)
    rescue ConfigurationError, ProjectError => e
      Output.abort(message: e.message)
    ensure
      Yeah::Kernel.finish!
    end
  end
end
